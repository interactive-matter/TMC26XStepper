#include <SPI.h>
#include <TMC262Stepper.h>

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,2,3,4,700);
int curr_step;

void setup() {
  Serial.begin(9600);
  //set this according to you stepper
  //char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement
  tmc262Stepper.setSpreadCycleChopper(5,24,8,6,0);
  //tmc262Stepper.setRandomOffTime(1);

  Serial.println("start");
  tmc262Stepper.setMicrosteps(64);
  tmc262Stepper.start();
  Serial.println("started");
  tmc262Stepper.setSpeed(100);
  tmc262Stepper.setStallGuardTreshold(10,1);
  Serial.println("config finished");
}

void loop() {
  for (int i=8;i>=0;i--) {
    tmc262Stepper.readStatus();
    Serial.println("up");
    for (int i=0; i<64;i++) {
      tmc262Stepper.step(100);
      tmc262Stepper.readStatus();
    }
    Serial.println("down");
    for (int i=0; i<64;i++) {
      tmc262Stepper.step(-100);
      tmc262Stepper.readStatus();
    }
  }
}


