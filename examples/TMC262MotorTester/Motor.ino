unsigned int motor_counter = 0;
unsigned char motor_moved = 0;
void startMotor() {
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
  TCNT2=setupTimer2(10000);
  sei();
}

void runMotor() {
}

void setSpeed(unsigned int targetSpeed) {
  if (targetSpeed>0 && targetSpeed<MAX_SPEED) {
    Serial.print("Setting speed: "); 
    Serial.println(targetSpeed);
    tmc262Stepper.setSpeed(targetSpeed);
  } 
  else {
    Serial.print("improper speed ");
    Serial.println(targetSpeed);
  }
}

void setMicrostepping(int microstepping) {
  if (microstepping<1 || microstepping>256) {
    Serial.print("Improperd microstepping setting [1...256]: ");
    Serial.print(microstepping);
  } 
  else {
    tmc262Stepper.setMicrosteps(microstepping);
  }
}

void setStallGuardTreshold(int treshold) {
  if (treshold<-64 || treshold > 63) {
    Serial.print("Improper Stall Guard Treshold [-64...63]: ");
    Serial.println(treshold);
  } 
  else {
    tmc262Stepper.setStallGuardTreshold(treshold,0);
  }
}

//from http://www.uchobby.com/index.php/2007/11/24/arduino-interrupts/
//Setup Timer2.s
//Configures the ATMega168 8-Bit Timer2 to generate an interrupt
//at the specified frequency.
//Returns the timer load value which must be loaded into TCNT2
//inside your ISR routine.
//See the example usage below.
unsigned char setupTimer2(float timeoutFrequency){
  unsigned char result; //The timer load value.

  //Calculate the timer load value
  result=(int)((257.0-(TIMER_CLOCK_FREQ/timeoutFrequency))+0.5);
  //The 257 really should be 256 but I get better results with 257.

  //Timer2 Settings: Timer Prescaler /8, mode 0
  //Timer clock = 16MHz/8 = 2Mhz or 0.5us
  //The /8 prescale gives us a good range to work with
  //so we just hard code this for now.
  TCCR2A = 0;
  TCCR2B = 0<<CS22 | 1<<CS21 | 0<<CS20;

  //Timer2 Overflow Interrupt Enable
  TIMSK2 = 1<<TOIE2;

  //load the timer for its first cycle
  TCNT2=result;

  return(result);
}

ISR(TIMER2_OVF_vect) {
  motor_moved = tmc262Stepper.move();
  motor_counter++;

}

