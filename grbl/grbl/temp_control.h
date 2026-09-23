/*
  temp_control.h - M101 heating-wire
  Manual addition to grbl 1.1
*/
 
#ifndef temp_control_h
#define temp_control_h
 
// Drives the feedback-potentiometer knob (via an L9110 gearmotor driver) to
// the position corresponding to r_percent (0-100), blocking until settled
// or until MOVE_TIMEOUT_MS elapses.
void temp_control_set(float r_percent);
 
#endif
 
