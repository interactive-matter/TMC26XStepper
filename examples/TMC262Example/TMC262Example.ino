#include <SPI.h>
#include <TMC262Stepper.h>

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 3, step pin 4 and a current of 300mA
TMC262Stepper tmc262Stepper = TMC262Stepper(200,2,3,4,700);
int curr_step;
int speed =  0;
int speedDirection = 100;
int maxSpeed = 1000;

void setup() {
  Serial.begin(9600);
  Serial.println("==============================");
  Serial.println("TMC262 Stepper Driver Demo App");
  Serial.println("==============================");
  //set this according to you stepper
  Serial.println("Configuring stepper driver");
  //char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement
  tmc262Stepper.setSpreadCycleChopper(2,24,8,6,0);
  tmc262Stepper.setRandomOffTime(0);
  
  tmc262Stepper.setMicrosteps(64);
  tmc262Stepper.setStallGuardTreshold(9,1);
  Serial.println("config finished, starting");
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


