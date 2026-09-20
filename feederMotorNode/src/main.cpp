/*
 * FeederMotor.ino
 * ------------------------------------------------------------------
 * CAN-controlled STEP/DIR stepper node.
 * Listens for ID_FEEDER_MOTOR_CMD (pos in mm, uint16) and moves a
 * lead-screw/belt axis to that position. Homes to MIN against a
 * limit switch on boot, grbl-style (seek -> back off -> slow
 * re-approach -> back off to pull-off distance).
 *
 * Library required: "MCP_CAN Library" by coryjfowler
 *   (Arduino IDE -> Library Manager -> search "mcp_can")
 *
 * Wiring (as given):
 *   MCP2515  SCK -> 13
 *            SI  -> 11
 *            SO  -> 12
 *            CS  -> 10   (these are the default hardware SPI pins
 *                         on an Uno/Nano, so only CS needs to be
 *                         told to the library)
 *   STEP -> 2
 *   DIR  -> 3
 *   Limit switch -> 9  (NC switch, external pull-down: reads HIGH
 *                       when NOT pressed, LOW when pressed/tripped)
 * ------------------------------------------------------------------
 */

#include <SPI.h>
#include <mcp_can.h>
#include "../../shared/canIds.h"

// ============================================================
//  USER CONFIG -- edit these for your hardware. All are baked
//  into the firmware at compile time (no EEPROM / runtime config).
// ============================================================

// --- Motion scaling -----------------------------------------
// PLACEHOLDER -- replace with your real value once measured
// (steps_per_rev * microstep / (mm per rev of leadscrew/pulley)).
#define STEPS_PER_MM        80.0f

// Flip this if the axis moves the wrong way relative to
// increasing position commands.
#define INVERT_DIR          false

// --- Travel / soft limits ------------------------------------
#define MAX_TRAVEL_MM        200.0f   // soft limit, PLACEHOLDER -- tune to your rail length
#define MIN_TRAVEL_MM        0.0f     // position after homing + pull-off

// --- Speeds -----------------------------------------------------
#define MAX_FEEDRATE_MM_S      40.0f   // normal move speed
#define HOMING_SEEK_MM_S        15.0f  // fast approach toward switch
#define HOMING_FEED_MM_S         3.0f  // slow, precise re-approach
#define HOMING_PULLOFF_MM        2.0f  // back-off distance after each touch

#define STEP_PULSE_US            10     // step pulse width (driver dependent, 5us is safe for most)

// ============================================================
//  PINS
// ============================================================
#define CAN_CS_PIN    10
#define STEP_PIN       2
#define DIR_PIN        3
#define LIMIT_PIN      9   // homes to MIN

// ============================================================
//  Derived constants
// ============================================================
static const long MAX_STEPS    = lround(MAX_TRAVEL_MM * STEPS_PER_MM);
static const long PULLOFF_STEPS = lround(HOMING_PULLOFF_MM * STEPS_PER_MM);

static const unsigned long RUN_STEP_INTERVAL_US   = (unsigned long)(1000000.0f / (MAX_FEEDRATE_MM_S  * STEPS_PER_MM));
static const unsigned long SEEK_STEP_INTERVAL_US  = (unsigned long)(1000000.0f / (HOMING_SEEK_MM_S    * STEPS_PER_MM));
static const unsigned long FEED_STEP_INTERVAL_US  = (unsigned long)(1000000.0f / (HOMING_FEED_MM_S    * STEPS_PER_MM));

MCP_CAN CAN(CAN_CS_PIN);

// Motion state
volatile long currentSteps = 0;
volatile long targetSteps  = 0;
unsigned long lastStepTime = 0;
bool homed = false;

// ---- low level helpers -----------------------------------------

// positive = increasing position (away from the MIN switch)
void setDir(bool positive) {
  bool level = positive ? HIGH : LOW;
  if (INVERT_DIR) level = !level;
  digitalWrite(DIR_PIN, level);
}

// Blocking single step, used only during homing.
void stepBlocking(unsigned long intervalUs) {
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(STEP_PULSE_US);
  digitalWrite(STEP_PIN, LOW);
  unsigned long rest = (intervalUs > STEP_PULSE_US) ? (intervalUs - STEP_PULSE_US) : 0;
  delayMicroseconds(rest);
}

bool limitTripped() {
  // NC switch + external pull-down: HIGH = not pressed, LOW = pressed
  return digitalRead(LIMIT_PIN) == LOW;
}

// ---- homing (grbl-style 2-touch homing) -------------------------
void homeAxis() {
  Serial.println(F("Homing..."));

  // Phase 1: fast seek toward the switch
  setDir(false);
  while (!limitTripped()) {
    stepBlocking(SEEK_STEP_INTERVAL_US);
  }
  delay(50);

  // Phase 2: back off
  setDir(true);
  for (long i = 0; i < PULLOFF_STEPS; i++) stepBlocking(SEEK_STEP_INTERVAL_US);
  delay(50);

  // Phase 3: slow, precise re-approach
  setDir(false);
  while (!limitTripped()) {
    stepBlocking(FEED_STEP_INTERVAL_US);
  }
  delay(50);

  // Phase 4: back off to the defined pull-off / zero position
  setDir(true);
  for (long i = 0; i < PULLOFF_STEPS; i++) stepBlocking(SEEK_STEP_INTERVAL_US);

  currentSteps = PULLOFF_STEPS;
  targetSteps  = PULLOFF_STEPS;
  homed = true;

  Serial.println(F("Homing complete."));
}

// ---- CAN handling ------------------------------------------------
void pollCAN() {
  if (CAN_MSGAVAIL != CAN.checkReceive()) return;

  uint8_t len = 0;
  uint8_t buf[8];
  unsigned long rxId;
  CAN.readMsgBuf(&rxId, &len, buf);

  if (rxId == ID_FEEDER_MOTOR_CMD && len >= 2) {
    uint16_t posMM = unpackU16(buf);
    long steps = lround((float)posMM * STEPS_PER_MM);

    // soft limits
    if (steps < 0) steps = 0;
    if (steps > MAX_STEPS) steps = MAX_STEPS;

    if (homed) {
      targetSteps = steps;
    }
  }
}

// ---- non-blocking motion, called every loop() --------------------
void runStepper() {
  if (!homed || currentSteps == targetSteps) return;

  if (micros() - lastStepTime < RUN_STEP_INTERVAL_US) return;

  bool positive = targetSteps > currentSteps;

  // Safety: don't drive further into a tripped limit switch
  if (!positive && limitTripped()) {
    targetSteps = currentSteps; // abandon the move
    return;
  }

  setDir(positive);
  digitalWrite(STEP_PIN, HIGH);
  delayMicroseconds(STEP_PULSE_US);
  digitalWrite(STEP_PIN, LOW);

  currentSteps += positive ? 1 : -1;
  lastStepTime = micros();
}

// ============================================================
void setup() {
  Serial.begin(115200);

  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(LIMIT_PIN, INPUT); // external pull-down already on the board, no INPUT_PULLUP

  while (CAN_OK != CAN.begin(MCP_ANY, CAN_500KBPS, MCP_8MHZ)) {
    Serial.println(F("CAN init failed, retrying..."));
    delay(200);
  }
  CAN.setMode(MCP_NORMAL);
  Serial.println(F("CAN init OK"));

  homeAxis();
}

void loop() {
  pollCAN();
  runStepper();
}
