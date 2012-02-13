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
}

void constantoff(int theValue) {
  println("Constant off "+theValue);
}

void blanktime(int theValue) {
  println("blank time "+theValue);
}

void setHysteresis(int start, int end) {
  println("hystereis from "+start+" to "+end);
}

void setHysteresisDecrement(int theValue) {
  println("Hysteresis decrement "+theValue);
}
