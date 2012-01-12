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
    Serial.print('S');
    Serial.print(tmc262Stepper.getSpeed(),DEC);
    Serial.print(',');
    Serial.print('m');
    Serial.print(tmc262Stepper.getMicrosteps(),DEC);
    Serial.print(',');
    if (moving) {
      Serial.print("sg");
      Serial.print(tmc262Stepper.getCurrentStallGuardReading(),DEC);
      Serial.print(',');
      Serial.print('p');
      Serial.print(tmc262Stepper.getMotorPosition(),DEC);
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
  }
  //at the end delete buffer
  inputBufferPosition=0;
  inputBuffer[0]=0;
}

int decode(unsigned char startPosition) {
  int result=0;
  for (unsigned char i=startPosition; i< (INPUT_BUFFER_LENGTH+1) && inputBuffer[i]!=0; i++) {
    char number = inputBuffer[i];
    //this very dumb approac can lead to errors, but we expect only numbers after the command anyway
    if (number <= '9' && number >='0') {
      result *= 10;
      result += number - '0';
    } 
  }
  return result;
}






