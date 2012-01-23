String channelAStatus=null;
String channelBStatus=null;
String temperatureStatus=null;

void speed(int theSpeed) {
  if (!settingStatus) {
    int speed = (int) theSpeed;
    println("setting speed to "+speed);
    arduinoPort.write("S"+speed+"\n");
  }
}

void run(int value) {
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
  if (value==sgtSlider.max()) {
    sgtPlus.lock();
  } 
  else {
    sgtPlus.unlock();
  }
  if (value==sgtSlider.min()) {
    sgtMinus.lock();
  } 
  else {
    sgtMinus.unlock();
  }
}

void sgtplus(int value) {
  sgtSlider.setValue(sgtSlider.value()+1);
}

void sgtminus(int value) {
  sgtSlider.setValue(sgtSlider.value()-1);
}

void sgfilter(int value) {
  if (!settingStatus) {
    println("filter: "+value);
    arduinoPort.write("f"+value+"\n");
  }
}  

void current(float value) {
  if (!settingStatus) {
    int realValue=(int)(value*1000.0);
    println("current: "+((float)realValue/1000.0)+" = "+realValue);
    arduinoPort.write("c"+realValue+"\n");
  }
}

void setCurrent(int current) {
  currentSlider.setValue((float)current/1000.0);
}

void setDirection(int direction) {
  if (direction<0) {
    directionButtons.activate(1);
  } 
  else {
    directionButtons.activate(0);
  }
  if (!settingStatus) {
    if (direction<0) {
      println("back");
      arduinoPort.write("d-1\n");
    } 
    else {
      arduinoPort.write("d1\n");
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup() && !settingStatus) {
    if ("microstepping".equals(theEvent.group().name())) { 
      microstepping((int)theEvent.group().value());
    }
    if ("direction".equals(theEvent.group().name())) {
      setDirection((int)theEvent.group().value());
    }
  } else if (theEvent.isTab()) {
    activeTab = theEvent.tab();
    println("Tab: "+activeTab.name());
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
        sgtSlider.setValue(getValueOfToken(statusToken, 1));
      } 
      else if (statusToken.startsWith("f")) {
        sgFilterToggle.setValue(getValueOfToken(statusToken, 1));
      } 
      else if (statusToken.startsWith("d")) {
        setDirection(getValueOfToken(statusToken, 1));
      }
      else if (statusToken.startsWith("c")) {
        setCurrent(getValueOfToken(statusToken, 1));
      } 
      else if (statusToken.startsWith("a")) {
        if (statusToken.charAt(1)=='o') {
          channelAStatus="Open Load";
        } 
        else if (statusToken.charAt(1)=='g') {
          channelAStatus="Short to Ground!";
        } 
        else {
          channelAStatus=null;
        }
      } 
      else if (statusToken.startsWith("b")) {
        if (statusToken.charAt(1)=='o') {
          channelBStatus="Open Load";
        } 
        else if (statusToken.charAt(1)=='g') {
          channelBStatus="Short to Ground!";
        } 
        else {
          channelBStatus=null;
        }
      } 
      else if (statusToken.startsWith("x")) {
        if (statusToken.charAt(1)=='w') {
          temperatureStatus="Prewarning!";
        } 
        else if (statusToken.charAt(1)=='e') {
          temperatureStatus="Error";
        } 
        else {
          temperatureStatus=null;
        }
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
    println("Unable to decode '"+value+"'of '"+token+"' !");
    return 0;
  }
}

