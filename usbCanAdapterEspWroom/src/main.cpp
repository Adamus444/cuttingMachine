#include <Arduino.h>
#include <ESP32-TWAI-CAN.hpp>

// --- Pin choice ---------------------------------------------------------
// GPIO21/22 - same pins used in Espressif's own official TWAI examples for
// classic ESP32. Avoids the strapping pins (0, 2, 5, 12, 15) that can
// affect boot behavior if accidentally pulled by external hardware.
#define CAN_TX_PIN GPIO_NUM_22  // -> transceiver CTX / D
#define CAN_RX_PIN GPIO_NUM_21  // <- transceiver CRX / R

// Match this to whatever baud your Uno+MCP2515 test network already uses
// (500 kbps is a common default - check your existing sketches).
#define CAN_BAUD_KBPS 500

// Fixed CAN ID used for these text messages. Doesn't matter for a 2-node
// test bus, just has to match between sender/receiver if you filter on it.
#define TEXT_CAN_ID 0x700

bool canStarted = false;
unsigned long lastHeartbeat = 0;

void setup() {
  Serial.begin(115200);
  // Give the native-USB serial a moment to enumerate before printing.
  delay(1000);

  ESP32Can.setPins(CAN_TX_PIN, CAN_RX_PIN);
  ESP32Can.setSpeed(ESP32Can.convertSpeed(CAN_BAUD_KBPS));

  canStarted = ESP32Can.begin();
}

void loop() {
  // Heartbeat every second so you always see *something*, even if you
  // attached the serial monitor after setup() already ran and printed.
  if (millis() - lastHeartbeat >= 1000) {
    lastHeartbeat = millis();
    Serial.print("alive, CAN status: ");
    Serial.println(canStarted ? "OK" : "FAILED to start - check wiring/pins");
  }

  // ---- Serial -> CAN ----
  // Type a line (up to 8 chars) in the serial monitor, hit enter, it goes
  // out as one CAN frame's data payload.
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    line.trim();
    if (line.length() > 0) {
      CanFrame txFrame = {0};
      txFrame.identifier = TEXT_CAN_ID;
      txFrame.extd = 0;
      txFrame.data_length_code = min((size_t)8, line.length());
      for (int i = 0; i < txFrame.data_length_code; i++) {
        txFrame.data[i] = (uint8_t)line[i];
      }

      if (ESP32Can.writeFrame(txFrame)) {
        Serial.print("Sent: ");
        Serial.println(line);
      } else {
        Serial.println("Send FAILED (no ACK? check bus/other node)");
      }
    }
  }

  // ---- CAN -> Serial ----
  CanFrame rxFrame;
  if (ESP32Can.readFrame(rxFrame, 10)) { // 10ms poll timeout
    char text[9] = {0}; // +1 for null terminator
    int len = min((int)rxFrame.data_length_code, 8);
    memcpy(text, rxFrame.data, len);

    Serial.print("Received [ID 0x");
    Serial.print(rxFrame.identifier, HEX);
    Serial.print("]: ");
    Serial.println(text);
  }
}