unsigned int motor_counter = 0;
unsigned char motor_moved = 0;
int sgTreshold = 4;
int sgFilter = 0;
int direction = 1;

unsigned int lower_SG_treshhold = 0;
unsigned int upper_SG_treshhold = 0;
unsigned char number_of_SG_readings=0;
unsigned char current_increment_step_size=0;
unsigned char lower_current_limit=0;


char chopperMode = 0; //0 for spread, 1 for constant off
char t_off = 2;
char t_blank = 24;
char h_start = 8;
char h_end = 6;
char h_decrement = 0;


void startMotor() {
  Serial.println(F("Configuring stepper driver"));
  //char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement
  tmc262Stepper.setSpreadCycleChopper(t_off,t_blank,h_start,h_end,h_decrement);
  tmc262Stepper.setRandomOffTime(0);

  tmc262Stepper.setMicrosteps(32);
  tmc262Stepper.setStallGuardTreshold(sgTreshold,sgFilter);
  //  Serial.println("config finished, starting");
  digitalWrite(ENABLE_PIN,LOW);
  tmc262Stepper.start();
  tmc262Stepper.setSpeed(10);
  TCNT2=setupTimer2(10000);
  sei();
}

void runMotor() {
  if (running && !tmc262Stepper.isMoving()) {
    tmc262Stepper.step(direction*10000);
    Serial.println("run");
  }
  if (!running & tmc262Stepper.isMoving()) {
    tmc262Stepper.stop();
    Serial.println("stop");
  }
}

void setSpeed(unsigned int targetSpeed) {
  if (targetSpeed>0 && targetSpeed<MAX_SPEED) {
    Serial.print(F("Setting speed: ")); 
    Serial.println(targetSpeed);
    tmc262Stepper.setSpeed(targetSpeed);
  } 
  else {
    Serial.print(F("improper speed "));
    Serial.println(targetSpeed);
  }
}

void setMicrostepping(int microstepping) {
  if (microstepping<1 || microstepping>256) {
    Serial.print(F("Improperd microstepping setting [1...256]: "));
    Serial.print(microstepping);
  } 
  else {
    tmc262Stepper.setMicrosteps(microstepping);
  }
}

void setStallGuardTreshold(int treshold) {
  if (treshold<-64 || treshold > 63) {
    Serial.print(F("Improper Stall Guard Treshold [-64...63]: "));
    Serial.println(treshold);
  } 
  else {
    sgTreshold = treshold;
    tmc262Stepper.setStallGuardTreshold(treshold,sgFilter);
  }
}

void setStallGuardFilter(int filter) {
  if (filter) {
    sgFilter=1;
  } 
  else {
    sgFilter=0;
  }
  tmc262Stepper.setStallGuardTreshold(sgTreshold,sgFilter);
}

void setCurrent(int current) {
  if (current>0 && current <1700) {
    tmc262Stepper.setCurrent(current);
  } 
  else {
    Serial.print(F("Improper current {0 ... 1200}: "));
    Serial.print(current);
  }
}

void updateChopper() {
  //we can do only spread now
  if (chopperMode==0) {
    tmc262Stepper.setSpreadCycleChopper(t_off,t_blank,h_start,h_end,h_decrement);
  }    
}

void updateCoolStep() {
  tmc262Stepper.setCoolStepConfiguration(
    lower_SG_treshhold, upper_SG_treshhold, number_of_SG_readings,
    current_increment_step_size, lower_current_limit);
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




