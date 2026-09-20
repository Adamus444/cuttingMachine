/*
 * temp_control.c - M101 heating-wire PWM control (v2, spindle-independent)
 * Manual addition to grbl 1.1
 *
 * WHY THIS VERSION EXISTS:
 * The original version wrote directly to SPINDLE_OCR_REGISTER (Timer2's
 * OC2A compare register, physically wired to D11). That register/pin is
 * not "free real estate" - it's grbl's own spindle output, and grbl
 * actively rewrites it:
 *   - on every hard-limit alarm, grbl calls spindle_stop(), which clears
 *     the COM2A bits (disconnecting the timer from D11 entirely, not just
 *     zeroing the duty) and forces the pin low.
 *   - in laser mode ($32=1), the stepper segment ISR continuously
 *     rescales OCR2A during motion based on grbl's own (unset) spindle
 *     speed state.
 *   - on any modal re-sync (reset, cycle start, etc.), grbl re-asserts
 *     its spindle state (which, as far as grbl knows, is always "off",
 *     since M101 never touches grbl's internal spindle state).
 * Any of these silently disconnects D11 from the timer, so a later M101
 * call - which only touched the duty register, not the COM bits - could
 * not bring the voltage back.
 *
 * FIX: don't share the pin or the output-compare unit grbl uses at all.
 * Timer2 is still used (it's already clocked, ~1kHz, from grbl's own
 * spindle_init - reused here for the free-running counter), but instead
 * of routing it out through the hardware OC2A/D11 pin, this drives a
 * completely separate GPIO (A0 / PC0 by default) from two small ISRs
 * tied to Timer2's overflow and its *second*, independent compare unit
 * (OCR2B). grbl's spindle code (spindle_stop, hard-limit alarm handling,
 * laser-mode scaling, modal re-sync) only ever touches OCR2A and the
 * COM2A bits - it has no path to OCR2B, TIMSK2, or pin A0. Nothing left
 * to fight over, motion or alarms included.
 *
 * Wiring: MOSFET gate now goes on A0 (PC0) instead of D11.
 *   A0 -> gate resistor (~100-220R) -> MOSFET gate, plus a ~10k pulldown
 *   gate-to-source so the gate isn't floating before setup() runs.
 *   Use a logic-level MOSFET (Vgs(th) rated for ~5V drive). MOSFET
 *   source -> common GND with the Arduino; drain switches the 24V wire.
 *   (Swap TEMP_PIN_DDR/PORT/BIT below if you'd rather use a different
 *   spare pin - any unused analog pin used as digital I/O works fine.)
 *
 * As before: R (0-100%) sets duty 1:1 with wire voltage. No feedback
 * loop - this only sets the duty and returns; M101's own mc_dwell(P)
 * (already in the M101 handler) is what waits for the wire to heat up.
 */

#include "grbl.h"

// Output pin for the heater MOSFET gate - independent of grbl's spindle pin.
#define TEMP_PIN_DDR    DDRC
#define TEMP_PIN_PORT   PORTC
#define TEMP_PIN_BIT    3   // Uno Analog Pin A3, used as digital output


// Current duty, 0-255. Written by temp_control_set(), read by the ISRs.
static volatile uint8_t temp_duty = 0;

// Fires at the start of every Timer2 cycle (counter wraps 0xFF -> 0x00).
// Only used for the "somewhere in the middle" duty case - see
// temp_control_set() for why 0% and 100% are special-cased and don't
// rely on this firing at all.
ISR(TIMER2_OVF_vect)
{
  TEMP_PIN_PORT |= (1 << TEMP_PIN_BIT);
}

// Fires when Timer2's counter reaches OCR2B - i.e. at the duty threshold.
ISR(TIMER2_COMPB_vect)
{
  TEMP_PIN_PORT &= ~(1 << TEMP_PIN_BIT);
}

// (Re)configures Timer2's free-running counter (Fast PWM, top = 0xFF,
// ~976 Hz at 16 MHz / prescaler 64) with BOTH physical outputs (OC2A,
// OC2B) disconnected from their pins (COM2A/COM2B = 0) - we only want
// the counter and interrupts, never a hardware-driven pin from this
// timer. Deliberately NOT gated behind an "already initialized" flag:
// called on every M101, so even if something else stomped these
// registers in between, the very next M101 fully re-asserts them.
static void temp_pwm_reassert(void)
{
  TEMP_PIN_DDR |= (1 << TEMP_PIN_BIT);

  TCCR2A = (1 << WGM21) | (1 << WGM20);   // Fast PWM, top 0xFF, OC2A/OC2B off
  TCCR2B = (1 << CS22);                    // prescaler /64
}


// ------------------------------------------------------------
// Public entry point, called from M101's [10. Dwell] block.
// r_percent: 0-100, mapped linearly to 0-24V (via PWM duty) on the wire.
// ------------------------------------------------------------
void temp_control_set(float r_percent)
{
  if (r_percent < 0.0f) r_percent = 0.0f;
  if (r_percent > 100.0f) r_percent = 100.0f;

  uint8_t duty = (uint8_t)((r_percent / 100.0f) * 255.0f + 0.5f);

  cli();
  temp_pwm_reassert();
  temp_duty = duty;

  if (duty == 0) {
    // Fully off: don't rely on ISR timing at all, just hold the pin low.
    TIMSK2 &= ~((1 << TOIE2) | (1 << OCIE2B));
    TEMP_PIN_PORT &= ~(1 << TEMP_PIN_BIT);
  } else if (duty >= 255) {
    // Fully on: hold the pin high, no toggling needed.
    TIMSK2 &= ~((1 << TOIE2) | (1 << OCIE2B));
    TEMP_PIN_PORT |= (1 << TEMP_PIN_BIT);
  } else {
    // Somewhere in between: let the two ISRs do the toggling in hardware
    // time, independent of whatever the rest of grbl is doing.
    OCR2B = duty;
    TIMSK2 |= (1 << TOIE2) | (1 << OCIE2B);
  }
  sei();

  printPgmString(PSTR("[MSG:Temp set]\r\n"));
}