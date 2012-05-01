String channelAStatus=null;
String channelBStatus=null;
String temperatureStatus=null;
boolean motor_connected = false;

RadioButton serialButtons;
Button serialOkButton;

StringBuilder serialStringBuilder = new StringBuilder();

void setupSerialConfig() {
  Tab defaultTab = controlP5.getTab("default");
  //add the list of serial interfaces - it get's populated later
  serialButtons = controlP5.addRadioButton("serialport", 200, 200);
  serialConfigElements.add(serialButtons);
  serialButtons.captionLabel().set("Select Serial Port");
  serialButtons.showBar();
  serialButtons.moveTo(defaultTab);
  //ad the ok button
  serialOkButton = controlP5.addButton("serialOk", 1, 200, height-300, 30, 30);
  serialConfigElements.add(serialOkButton);
  serialOkButton.setCaptionLabel("OK");
  runToggle.moveTo(defaultTab);

  //finally update the list of serial ports
  updateSerialPortList();
}

void updateSerialPortList() {
  //first remove all present serial ports
  List items = serialButtons.getItems();
  for (Object i:items) {
    Toggle item = (Toggle) i;
    serialButtons.removeItem(item.getName());
  }
  //add the serial ports
  String[] ports = Serial.list();
  for (int i=0; i< ports.length; i++) {
    serialButtons.addItem(ports[i],i);
  }
  serialButtons.setValue(-1);
  serialOkButton.setVisible(false);
}

void serialport(int value) {
  println("port "+ value);
  //ok button is only active if a serial port is selected
  serialOkButton.setVisible(value>-1);
}


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
      else if (statusToken.startsWith("e")) {
        int enabled = getValueOfToken(statusToken, 1);
        if (enabled!=0) {
          enabledToggle.setValue(1);
        } 
        else {
          enabledToggle.setValue(0);
        }
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
      else if (statusToken.startsWith("k")) {
        addCurrentReading(getValueOfToken(statusToken, 1));
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
      else if (statusToken.startsWith("Cm")) {
        //chopper mode is currently ignored
      } 
      else if (statusToken.startsWith("Co")) {
        constantOffSlider.setValue(getValueOfToken(statusToken, 2));
      }  
      else if (statusToken.startsWith("Cb")) {
        blankTimeSlider.setValue(getValueOfToken(statusToken, 2));
      } 
      else if (statusToken.startsWith("Cs")) {
        hysteresisStartSlider.setValue(getValueOfToken(statusToken, 2));
      } 
      else if (statusToken.startsWith("Ce")) {
        hysteresisEndSlider.setValue(getValueOfToken(statusToken, 2));
      } 
      else if (statusToken.startsWith("Cd")) {
        setHystDecrement(getValueOfToken(statusToken, 2));
      } 
      else if ("Ke+".equals(statusToken)) {
        coolStepActiveToggle.setValue(1);
      } 
      else if ("Ke-".equals(statusToken)) {
        coolStepActiveToggle.setValue(0);
      } 
      else if (statusToken.startsWith("Kl")) {
        coolStepMinSlider.setValue(getValueOfToken(statusToken, 2));
      } 
      else if (statusToken.startsWith("Ku")) {
        coolStepMaxSlider.setValue(getValueOfToken(statusToken, 2));
      }
      else if (statusToken.startsWith("Kn")) {
        coolStepDecrementButtons.activate(getValueOfToken(statusToken, 2));
      } 
      else if (statusToken.startsWith("Ki")) {
        coolStepIncrementButtons.activate(getValueOfToken(statusToken, 2));
      }
      else if (statusToken.startsWith("Km")) {
        coolStepMinButtons.activate(getValueOfToken(statusToken, 2));
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

