#include <SPI.h>
#include <TMC262Stepper.h>

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,2,3,4,300);
int curr_step;

void setup() {
  Serial.begin(9600);
  Serial.println("start");
  tmc262Stepper.start();
}

void loop() {
  Serial.println("up");
  for (int i=0; i< 2000; i++) {
    tmc262Stepper.step(1);
    delay(10);
  }
  Serial.println("down");
  for (int i=0; i< 2000; i++) {
    tmc262Stepper.step(-1);
    delay(10);
  }
}

