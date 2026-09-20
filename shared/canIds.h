#pragma once
#include <stdint.h>

//  bit: 10 9 8 | 7 6 5 4 | 3 2 1 0
//       [purpose] [ node ] [ msg ]
//         3 bits   4 bits   4 bits
//        (0-7)     (0-15)   (0-15)

#define CAN_BITRATE_KBPS  500
#define MAKE_ID(purpose, node, msg) (((purpose) << 8) | ((node) << 4) | (msg))

// Purposes 
#define PURPOSE_CRITICAL 0
#define PURPOSE_COMMAND 1
#define PURPOSE_TELEMETRY 2
#define PURPOSE_STATUS 3

// Nodes
#define NODE_CONTROLLER 0
#define NODE_FEEDER_MOTOR 1

// Message IDs 
// Each comment IS the payload spec — keep it accurate.

// data[0-1] = pos(uint16, mm)
#define ID_FEEDER_MOTOR_CMD MAKE_ID(PURPOSE_COMMAND, NODE_FEEDER_MOTOR, 0)

// Pack/unpack helpers
static inline void packU16(uint8_t* buf, uint16_t val) {
    buf[0] = val & 0xFF;
    buf[1] = (val >> 8) & 0xFF;
}
static inline uint16_t unpackU16(const uint8_t* buf) {
    return (uint16_t)(buf[0] | (buf[1] << 8));
}