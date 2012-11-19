#include <SPI.h>
#include <TMC26XStepper.h>

//we have a stepper motor with 200 steps per rotation, CS pin 2, dir pin 6, step pin 7 and a current of 300mA
TMC26XStepper tmc26XStepper = TMC26XStepper(200,2,6,7,700);
int curr_step;
int speed =  0;
int speedDirection = 100;
int maxSpeed = 1000;

void setup() {
  Serial.begin(9600);
  Serial.println("==============================");
  Serial.println("TMC26X Stepper Driver Demo App");
  Serial.println("==============================");
  //set this according to you stepper
  Serial.println("Configuring stepper driver");
  //char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement
  tmc26XStepper.setSpreadCycleChopper(2,24,8,6,0);
  tmc26XStepper.setRandomOffTime(0);
  
  tmc26XStepper.setMicrosteps(32);
  tmc26XStepper.setStallGuardThreshold(4,0);
  Serial.println("config finished, starting");
  tmc26XStepper.start();
  Serial.println("started");
}

void loop() {
  if (!tmc26XStepper.isMoving()) {
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
    tmc26XStepper.setSpeed(speed);
    //we want some kind of constant running time - so the length is just a product of speed
    Serial.print("Going ");
    Serial.print(10*speed);
    Serial.println(" steps");
    tmc26XStepper.step(10*speed);
  } else {
    //we put out the status every 100 steps
    if (tmc26XStepper.getStepsLeft()%100==0) {
      Serial.print("Stall Guard: ");
      Serial.println(tmc26XStepper.getCurrentStallGuardReading());
    }    
  }  
  tmc26XStepper.move();
}


