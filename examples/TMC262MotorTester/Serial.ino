#define INPUT_BUFFER_LENGTH 32

#define SERIAL_SPEED 115200
#define STATUS_COUNTER 100

char inputBuffer[INPUT_BUFFER_LENGTH+1]; //ad on character to keep the trainling 0
unsigned char inputBufferPosition;

void startSerial() {
  Serial.begin(SERIAL_SPEED);
  Serial.println("=================================");
  Serial.println("TMC262 Stepper Driver Motor Tuner");
  Serial.println("=================================");
  //empty the input buffer
  for (unsigned char i=0; i< INPUT_BUFFER_LENGTH+1; i++) {
    inputBuffer[i]=0;
  }
  inputBufferPosition=0;
}

void loopSerial() {
  if (Serial.available()>0 && inputBufferPosition<INPUT_BUFFER_LENGTH) {
    char c = Serial.read();
    //Read the char
    inputBuffer[inputBufferPosition]=c;
    inputBufferPosition++;
    //always terminate the string
    inputBuffer[inputBufferPosition]=0;
    //and if the line ended we execute the command
    if (c=='\n') {
      executeSerialCommand();   
    }
  }
  if (motor_moved) {
    Serial.print("#sg");
    Serial.print(tmc262Stepper.getCurrentStallGuardReading(),DEC);
    Serial.print(",p");
    Serial.print(tmc262Stepper.getMotorPosition(),DEC);
    Serial.println(',');
    motor_moved=0;
  }
  if (motor_counter>STATUS_COUNTER) {
    motor_counter=0;
    char moving = tmc262Stepper.isMoving();
    Serial.print('#');
    if (moving) {
      Serial.print('r');
    } 
    else {
      Serial.print('s');
    }
    Serial.print(',');
    Serial.print('d');
    Serial.print(direction);
    Serial.print(',');
    Serial.print("c");
    Serial.print(tmc262Stepper.getCurrent(),DEC);
    Serial.print(',');
    Serial.print('S');
    Serial.print(tmc262Stepper.getSpeed(),DEC);
    Serial.print(',');
    Serial.print('m');
    Serial.print(tmc262Stepper.getMicrosteps(),DEC);
    Serial.print(',');
    if (moving) {
    }
    Serial.print(',');
    Serial.print("t");
    Serial.print(tmc262Stepper.getStallGuardTreshold(),DEC);
    Serial.print(',');
    Serial.print("f");
    Serial.print(tmc262Stepper.getStallGuardFilter(),DEC);
    Serial.print(',');
    //detect the winding status
    if (tmc262Stepper.isOpenLoadA()) {
      Serial.print("ao,");
    } 
    else if(tmc262Stepper.isShortToGroundA()) {
      Serial.print("ag,");
    } 
    else {
      Serial.print("a-,");
    }
    //detect the winding status
    if (tmc262Stepper.isOpenLoadB()) {
      Serial.print("bo,");
    } 
    else if(tmc262Stepper.isShortToGroundB()) {
      Serial.print("bg,");
    } 
    else {
      Serial.print("b-,");
    }
    char temperature = tmc262Stepper.getOverTemperature();
    if (temperature==0) {
      Serial.print("x-,");
    } 
    else if (temperature==TMC262_OVERTEMPERATURE_PREWARING) {
      Serial.print("xw,");
    } 
    else {
      Serial.print("xe,");
    }
    if (tmc262Stepper.isEnabled()) {
      Serial.print("e1,");
    } 
    else {
      Serial.print("e0,");
    }
    //write out the current chopper config
    Serial.print("Cm");
    Serial.print(chopperMode,DEC);
    Serial.print(",Co");
    Serial.print(t_off,DEC);
    Serial.print(",Cb");
    Serial.print(t_blank,DEC);
    if (chopperMode==0) {
      Serial.print(",Cs");
      Serial.print(h_start,DEC);
      Serial.print(",Ce");
      Serial.print(h_end,DEC);
      Serial.print(",Cd");
      Serial.print(h_decrement,DEC);
    }
    Serial.print(',');
    Serial.println();
  }
}

void executeSerialCommand() {
  Serial.print("Executing ");
  Serial.println(inputBuffer);
  //stimple runn & stop commands
  switch(inputBuffer[0]) {
  case 's':
    running = 0;
    break;
  case 'r':
    running = -1;
    break;
  case 'S':
    {
      int targetSpeed = decode(1);
      setSpeed(targetSpeed);
    }
    break;
  case 'm':
    {
      int microstepping = decode(1);
      setMicrostepping(microstepping);
    }
    break;
  case 't':
    {
      int treshold = decode(1);
      setStallGuardTreshold(treshold);
    }
    break;
  case 'f':
    {
      int filter = decode(1);
      setStallGuardFilter(filter);
    }
    break;
  case 'd':
    {
      int value = decode(1);
      tmc262Stepper.stop();
      if (value<0) {
        direction=-1;
      } 
      else {
        direction=1;
      }
    }
    break;
  case 'c':
    {
      int current = decode(1);
      setCurrent(current);
    }
    break;
  case 'e':
    {
      int enabled = decode(1);
      if (enabled) {
        tmc262Stepper.setEnabled(true);
      } 
      else {
        tmc262Stepper.setEnabled(false);
      }
    }
    break;
  case 'C':
      switch(inputBuffer[1]) {
      case 'o':
        {
          int value = decode(2);
          if (value>0 && value<16) {
            t_off=value;
            updateChopper();
          }
        }
        break;
      case 'b':
        {
          int value = decode(2);
          if (value>=0 && value<=3) {
            t_blank=value;
            updateChopper();
          }
        }
        break;
      }
    break;
  }
  //at the end delete buffer
  inputBufferPosition=0;
  inputBuffer[0]=0;
}

int decode(unsigned char startPosition) {
  int result=0;
  boolean negative = false;
  if (inputBuffer[startPosition]=='-') {
    negative=true;
    startPosition++;
  }
  for (unsigned char i=startPosition; i< (INPUT_BUFFER_LENGTH+1) && inputBuffer[i]!=0; i++) {
    char number = inputBuffer[i];
    //this very dumb approac can lead to errors, but we expect only numbers after the command anyway
    if (number <= '9' && number >='0') {
      result *= 10;
      result += number - '0';
    } 
  }
  if (negative) {
    return -result;
  } 
  else {
    return result;
  }
}
















