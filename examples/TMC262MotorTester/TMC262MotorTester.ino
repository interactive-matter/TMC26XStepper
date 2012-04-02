#include <SPI.h>
#include <TMC262Stepper.h>

//you may adapt this to your shield or breakout board connection
#define CS_PIN 2
#define DIR_PIN 6
#define STEP_PIN 7
#define ENABLE_PIN 8 //if it is not connected it won't be a problem


#define TIMER_CLOCK_FREQ 2000000.0 //2MHz for /8 prescale from 16MHz
#define INITIAL_CURRENT 500 //in mA
#define MAX_SPEED 1000


//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,CS_PIN,DIR_PIN,STEP_PIN,INITIAL_CURRENT);
char running;

void setup() {
  //configure the enable pin
  pinMode(ENABLE_PIN, OUTPUT);
  digitalWrite(ENABLE_PIN,HIGH);

  startSerial();
  startMotor();
  //set this according to you stepper
  Serial.println(F("started"));
}

void loop() {
  loopSerial();
  runMotor();
}



