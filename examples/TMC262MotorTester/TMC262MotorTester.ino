#include <SPI.h>
#include <TMC262Stepper.h>

#define CS_PIN 2
#define DIR_PIN 6
#define STEP_PIN 7
#define ENABLE_PIN 8 //if it is not connected it won't be a problem

#define INITIAL_CURRENT 500 //in mA
#define MAX_SPEED 1000

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,CS_PIN,DIR_PIN,STEP_PIN,INITIAL_CURRENT);
int curr_step;
char running;

void setup() {
  //configure the enable pin
  pinMode(ENABLE_PIN, OUTPUT);
  digitalWrite(ENABLE_PIN,HIGH);
  
  startSerial();
  //set this according to you stepper
  Serial.println("Configuring stepper driver");
  //char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement
  tmc262Stepper.setSpreadCycleChopper(2,24,8,6,0);
  tmc262Stepper.setRandomOffTime(0);
  
  tmc262Stepper.setMicrosteps(32);
  tmc262Stepper.setStallGuardTreshold(4,0);
//  Serial.println("config finished, starting");
  digitalWrite(ENABLE_PIN,LOW);
  tmc262Stepper.start();
  tmc262Stepper.setSpeed(10);
  Serial.println("started");
}

void loop() {
  loopSerial();
  tmc262Stepper.move();
  if (running && !tmc262Stepper.isMoving()) {
    tmc262Stepper.step(10000);
    Serial.println("run");
  }
  if (!running & tmc262Stepper.isMoving()) {
    tmc262Stepper.stop();
    Serial.println("stop");
  }
}

void setSpeed(unsigned int targetSpeed) {
  if (targetSpeed>1 && targetSpeed<MAX_SPEED) {
  tmc262Stepper.setSpeed(targetSpeed);
  } else {
    Serial.print("improper speed ");
    Serial.println(targetSpeed);
  }
}
  
