
void speed(float theSpeed) {
  if (!settingStatus) {
    int speed = (int) theSpeed;
    println("setting speed to "+speed);
    arduinoPort.write("S"+speed+"\n");
  }
}

void run(int theValue) {
  if (!settingStatus) {
    println("button pressed");
    if (running) {
      println("stopping motor");
      arduinoPort.write("s\n");
      running = false;
    } 
    else {
      println("starting motor");
      arduinoPort.write("r\n");
      running = true;
    }
  }
}

void microstepping(int value) {
  if (!settingStatus) {
    println("microstepping: "+value);
    arduinoPort.write("m"+value+"\n");
  }
}

void stallguardtreshold(int value) {
  if (!settingStatus) {
    println("stall guard treshold: "+value);
    arduinoPort.write("t"+value+"\n");
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup() && !settingStatus) {
    if ("microstepping".equals(theEvent.group().name())) { 
      microstepping((int)theEvent.group().value());
    }
  }
}

StringBuilder serialStringBuilder = new StringBuilder();

void decodeSerial() {
  while (arduinoPort.available ()>0) {
    char c = arduinoPort.readChar();
    serialStringBuilder.append(c);
    if (c=='\n') {
      decodeSerial(serialStringBuilder.toString());
      serialStringBuilder = new StringBuilder();
    }
  }
}

void decodeSerial(String line) {
  settingStatus=true;
  if (line.startsWith("#")) {
    String status = line.substring(1);
    StringTokenizer statusTokenizer = new StringTokenizer(status, ",");
    while (statusTokenizer.hasMoreTokens ()) {
      String statusToken = statusTokenizer.nextToken();
      if ("s".equals(statusToken)) {
        runToggle.setValue(0);
      } 
      else if ("r".equals(statusToken)) {
        runToggle.setValue(1);
      } 
      else if (statusToken.startsWith("S")) {
        speedSlider.setValue(getValueOfToken(statusToken, 1));
      } 
      else if (statusToken.startsWith("m")) {
        microsteppingButtons.activate(String.valueOf(getValueOfToken(statusToken, 1)));
      } 
      else if (statusToken.startsWith("sg")) {
        addStallGuardReading(getValueOfToken(statusToken, 2));
      } 
      else if (statusToken.startsWith("p")) {
        addPositionReading(getValueOfToken(statusToken, 1));
      } 
      else if (statusToken.startsWith("t")) {
        println("sgt "+getValueOfToken(statusToken, 1));
        sgtSlider.setValue(getValueOfToken(statusToken, 1));
      }
    }
  } 
  else {
    println(line);
  }
  settingStatus=false;
}

int getValueOfToken(String token, int position) {
  String value = token.substring(position);
  try {
    return Integer.valueOf(value);
  } 
  catch (NumberFormatException e) {
    println("Unable to decode '"+value+"'!");
    return 0;
  }
}

