Slider constantOffSlider;
Slider blankTimeSlider;
Toggle randomOffTimeToggle;
RadioButton ChopperModeButtons;
//for constant off time chopeer
Slider fastDecaySlider;
Slider sineWaveOffsetSlider;
Toggle currentComparatorToggle;
//for spread chopper
Slider hysteresisStartSlider;
Slider hysteresisEndSlider;
RadioButton hysteresisDecrementButtons;

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

  hysteresisStartSlider =  controlP5.addSlider("hysteresisstart", 0, 8, 2, 15, 120, 400, 20);
  hysteresisStartSlider.setCaptionLabel("Hysteresis Start");
  hysteresisStartSlider.moveTo(configureTab);
  
  hysteresisEndSlider =  controlP5.addSlider("hysteresisend", -3, 12, 2, 15, 160, 400, 20);
  hysteresisEndSlider.setCaptionLabel("Hysteresis End");
  hysteresisEndSlider.moveTo(configureTab);

  hysteresisDecrementButtons =controlP5.addRadioButton("decrement", 15, 200);
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

void hysteresisstart(int start) {
  if (!settingStatus) {
    println("hystereis start "+start);
  }
}

void hysteresisend(int end) {
  if (!settingStatus) {
    println("hystereis end "+end);
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

