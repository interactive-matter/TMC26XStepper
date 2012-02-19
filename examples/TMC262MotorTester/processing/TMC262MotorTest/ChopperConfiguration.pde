PImage spreadChopperImage;

void setupChooperConfig() {
  // add a vertical slider for speed  
  constantOffSlider = controlP5.addSlider("constantoff", 1, 15, 1, 15, 40, 400, 20);
  constantOffSlider.setCaptionLabel("Constant Off Time");
  constantOffSlider.setSliderMode(Slider.FIX);
  constantOffSlider.moveTo(configureTab);

  blankTimeSlider =  controlP5.addSlider("blanktime", 0, 3, 2, 15, 80, 400, 20);
  blankTimeSlider.setCaptionLabel("Blank Time");
  blankTimeSlider.moveTo(configureTab);

  hysteresisRange =  controlP5.addRange("hysteresisrange", 0, 18, 2, 8, 15, 120, 400, 20);
  hysteresisRange.setCaptionLabel("hysteresis start & end");
  hysteresisRange.moveTo(configureTab);

  hysteresisDecrementButtons =controlP5.addRadioButton("decrement", 15, 160);
  hysteresisDecrementButtons.addItem("fastest", 0);
  hysteresisDecrementButtons.addItem("fast", 1);
  hysteresisDecrementButtons.addItem("medium", 2);
  hysteresisDecrementButtons.addItem("slow", 3);
  hysteresisDecrementButtons.showBar();
  hysteresisDecrementButtons.moveTo(configureTab);

  spreadChopperImage = loadImage("hysteresis.png");
}

void drawChopper() {
  if (activeTab!=null && "default".equals(activeTab.name())) {
    image(spreadChopperImage, 200, 400);
  }
}

void constantoff(int theValue) {
  if (!settingStatus) {
    if (theValue>0 && theValue<16) {
      println("Constant off "+theValue);
      arduinoPort.write("cO"+theValue+"\n");
    } 
    else {
      println("invalid blank time of "+theValue);
    }
  }
}

void blanktime(int theValue) {
  if (!settingStatus) {
    if (theValue>=0 && theValue<=3) {
      println("blank time "+theValue);
      arduinoPort.write("cb"+theValue+"\n");
    }
  }
}

void setHysteresis(int start, int end) {
  if (!settingStatus) {
    println("hystereis from "+start+" to "+end);
  }
}

void setHysteresisDecrement(int theValue) {
  if (!settingStatus) {
    println("Hysteresis decrement "+theValue);
  }
}

void setHystDecrement(int value) {
  if (value>=0 && value<=3) {
    hysteresisDecrementButtons.activate(value);
  } 
  else {
    println("this is no proper hysteresis decerement value: "+value);
  }
}

void setHystStart(int value) {
  hysteresisRange.setHighValue(value);
}

void setHystEnd(int value) {
  hysteresisRange.setLowValue(value);
}

