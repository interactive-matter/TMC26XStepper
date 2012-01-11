#define INPUT_BUFFER_LENGTH 32

#define SERIAL_SPEED 115200

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
    int targetSpeed = decode(1);
    setSpeed(targetSpeed);
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


