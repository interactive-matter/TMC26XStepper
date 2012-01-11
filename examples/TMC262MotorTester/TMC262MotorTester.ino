#include <SPI.h>
#include <TMC262Stepper.h>

#define CS_PIN 2
#define DIR_PIN 6
#define STEP_PIN 7
#define ENABLE_PIN 8 //if it is not connected it won't be a problem

#define INITIAL_CURRENT 500 //in mA

#define SERIAL_SPEED 9600

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,CS_PIN,DIR_PIN,STEP_PIN,INITIAL_CURRENT);
int curr_step;
int speed =  0;
int speedDirection = 100;
int maxSpeed = 1000;

void setup() {
  //configure the enable pin
  pinMode(ENABLE_PIN, OUTPUT);
  digitalWrite(ENABLE_PIN,HIGH);
  
  //set this according to you stepper
  Serial.println("Configuring stepper driver");
  //char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement
  tmc262Stepper.setSpreadCycleChopper(2,24,8,6,0);
  tmc262Stepper.setRandomOffTime(0);
  
  tmc262Stepper.setMicrosteps(32);
  tmc262Stepper.setStallGuardTreshold(4,0);
  Serial.println("config finished, starting");
  digitalWrite(ENABLE_PIN,LOW);
  tmc262Stepper.start();
  Serial.println("started");
}

void loop() {
  if (!tmc262Stepper.isMoving()) {
    speed+=speedDirection;
    if (speed>maxSpeed) {
      speed = maxSpeed;
      speedDirection = -speedDirection;
    } else if (speed<0) {
      speedDirection = -speedDirection;
      speed=speedDirection;
    }
    //setting the speed
    Serial.print("setting speed to ");
    Serial.println(speed);
    tmc262Stepper.setSpeed(speed);
    //we want some kind of constant running time - so the length is just a product of speed
    Serial.print("Going ");
    Serial.print(10*speed);
    Serial.println(" steps");
    tmc262Stepper.step(10*speed);
  } else {
    //we put out the status every 100 steps
    if (tmc262Stepper.getStepsLeft()%100==0) {
      Serial.print("Stall Guard: ");
      Serial.println(tmc262Stepper.getCurrentStallGuardReading());
    }    
  }  
  tmc262Stepper.move();
}


