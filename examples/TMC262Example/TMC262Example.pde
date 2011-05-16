#include <SPI.h>
#include <TMC262Stepper.h>

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,2,3,4,400);
int curr_step;

void setup() {
  Serial.begin(9600);
  //set this according to you stepper
  tmc262Stepper.setSpreadCycleChopper(2,24,6,0,1);
  tmc262Stepper.setRandomOffTime(1);

  Serial.println("start");
  tmc262Stepper.start();
  tmc262Stepper.setSpeed(100);
}

void loop() {
  for (int i=8;i>=0;i--) {
    tmc262Stepper.setMicrosteps(1<<i);
    Serial.println("up");
    tmc262Stepper.step(6400);
    Serial.println("down");
    tmc262Stepper.step(-6400);
  }
}

