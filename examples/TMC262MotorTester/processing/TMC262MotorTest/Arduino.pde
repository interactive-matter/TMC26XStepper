String channelAStatus=null;
String channelBStatus=null;
String temperatureStatus=null;

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

