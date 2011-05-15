#include <SPI.h>
#include <TMC262Stepper.h>

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,2,3,4,300);
int curr_step;

void setup() {
  Serial.begin(9600);
  Serial.println("start");
  tmc262Stepper.start();
  tmc262Stepper.setSpeed(1000);
}

void loop() {
  Serial.println("up");
  tmc262Stepper.step(6400);
  Serial.println("down");
  tmc262Stepper.step(-6400);
}

