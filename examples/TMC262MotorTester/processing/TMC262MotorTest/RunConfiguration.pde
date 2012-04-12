
Slider speedSlider;
Toggle runToggle;
RadioButton directionButtons;
Toggle enabledToggle;
RadioButton microsteppingButtons;
Slider sgtSlider;
Button sgtPlus;
Button sgtMinus;
Toggle sgFilterToggle;
Slider currentSlider;
Slider coolStepMinSlider;
Slider coolStepMaxSlider;
Toggle coolStepActiveToggle;
RadioButton coolStepIncrementButtons;
RadioButton coolStepDecrementButtons;
RadioButton coolStepMinButtons;

void setupRunConfig() {
  //the run configuration
  //controlP5.getControlFont().setSize(10); - the font is too small, try to increase it!
  //add a button te let the motor run
  runToggle = controlP5.addToggle("run", false, 20, 40, 30, 30);
  runToggle.moveTo(runTab);
  //add some directions buttons
  directionButtons = controlP5.addRadioButton("direction", 20, 90);
  directionButtons.addItem("forward", 1);
  directionButtons.addItem("backward", -1);
  directionButtons.activate(0);
  directionButtons.moveTo(runTab);
  enabledToggle = controlP5.addToggle("enabled", false, 20, 220, 30, 30);
  enabledToggle.moveTo(runTab);

  // add a vertical slider for speed  
  speedSlider = controlP5.addSlider("speed", 1, 100, 10, 85, 40, 20, 210);
  speedSlider.moveTo(runTab);

  //ad a multilist for the microstepping setting
  microsteppingButtons = controlP5.addRadioButton("microstepping", 150, 40);
  microsteppingButtons.addItem("1", 1);
  microsteppingButtons.addItem("2", 2);
  microsteppingButtons.addItem("4", 4);
  microsteppingButtons.addItem("8", 8);
  microsteppingButtons.addItem("16", 16);
  microsteppingButtons.addItem("32", 32);
  microsteppingButtons.addItem("64", 64);
  microsteppingButtons.addItem("128", 128);
  microsteppingButtons.addItem("256", 256);
  microsteppingButtons.showBar();
  microsteppingButtons.moveTo(runTab);



  currentSlider = controlP5.addSlider("current", 0.46, maxCurrent, 0.4, 300, 50, 20, 210);
  currentSlider.moveTo(runTab);

  // add a vertical slider for stallGuard treshold  
  sgtSlider = controlP5.addSlider("stallguardtreshold", -64, 63, 0, 500, 40, 20, 150);
  sgtSlider.setSliderMode(Slider.FIX);
  sgtSlider.setCaptionLabel("Stall Guard Treshold");
  sgtSlider.moveTo(runTab);
  sgtPlus = controlP5.addButton("sgtplus", 0, 550, 40, 20, 20);
  sgtPlus.setCaptionLabel("+");
  sgtPlus.moveTo(runTab);
  sgtMinus = controlP5.addButton("sgtminus", 1, 550, 70, 20, 20);
  sgtMinus.setCaptionLabel("-");
  sgtMinus.moveTo(runTab);
  //ading some buttons to have finer sg control
  //adding a button for the filter
  sgFilterToggle = controlP5.addToggle("sgfilter", false, 500, 220, 30, 30);
  sgFilterToggle.setCaptionLabel("Stall GuardFilter");
  sgFilterToggle.moveTo(runTab);
  
  //add the coolstep sliders
  coolStepMaxSlider = controlP5.addSlider("coolStepUpper", 0, 480, 0, 750, 40, 20, 90);
  coolStepMaxSlider.setCaptionLabel("Cool Step Hysteresis");
  coolStepMaxSlider.moveTo(runTab);

  coolStepMinSlider = controlP5.addSlider("coolStepLower", 0, 480, 0, 750, 160, 20, 90);
  coolStepMinSlider.setCaptionLabel("Cool Step Minimum");
  coolStepMinSlider.moveTo(runTab);
  
  coolStepActiveToggle = controlP5.addToggle("coolStepActive", false, 850, 220, 30, 30);  
  coolStepActiveToggle.setCaptionLabel("Enable CoolStep");
  coolStepActiveToggle.moveTo(runTab);

  coolStepIncrementButtons = controlP5.addRadioButton("coolStepIncrement", 850, 40);
  coolStepIncrementButtons.captionLabel().set("Cool Step  Increment");
  coolStepIncrementButtons.addItem("1", 0);
  coolStepIncrementButtons.addItem("2", 1);
  coolStepIncrementButtons.addItem("4", 2);
  coolStepIncrementButtons.addItem("8", 3);
  coolStepIncrementButtons.showBar();
  coolStepIncrementButtons.moveTo(runTab);

  coolStepDecrementButtons = controlP5.addRadioButton("coolStepDecrement", 850, 110);
  coolStepDecrementButtons.captionLabel().set("Cool Step Decrement");
  coolStepDecrementButtons.addItem("32", 0);
  coolStepDecrementButtons.addItem("8", 1);
  coolStepDecrementButtons.addItem("2", 2);
  coolStepDecrementButtons.addItem("1", 3);
  coolStepDecrementButtons.showBar();
  coolStepDecrementButtons.moveTo(runTab);

  coolStepMinButtons = controlP5.addRadioButton("coolStepMin", 850, 180);
  coolStepMinButtons.addItem("1/2", 0);
  coolStepMinButtons.addItem("1/4", 1);
  coolStepMinButtons.showBar();
  coolStepMinButtons.moveTo(runTab);
}

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

void enabled(int value) {
  if (!settingStatus) {
    println("enabled: "+value);
    arduinoPort.write("e"+value+"\n");
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
    if (activeTab!=null && "run".equals(activeTab.name())) {
      motorCurrentBox.setValue(value);
    }
  }
}

void coolStepUpper(int value) {
  coolStepMax=value;
  if (!settingStatus) {
    arduinoPort.write("Ku"+value+"\n");
  }
}

void coolStepLower(int value) {
  coolStepMin = value;
  if (!settingStatus) {
    arduinoPort.write("Kl"+value+"\n");
  }
}


void setCoolStepIncrement(int value) {
  if (!settingStatus) {
    println("cool step increment :"+value);
    arduinoPort.write("Ki"+value+"\n");
  }
}

void setCoolStepDecrement(int value) {
  if (!settingStatus) {
    println("cool step decrement :"+value);
    arduinoPort.write("Kn"+value+"\n");
  }
}

void setCoolStepMin(int value) {
  if (!settingStatus) {
    println("cool step minimum :"+value);
    arduinoPort.write("Km"+value+"\n");
  }
}

void coolStepActive(int value) {
  if (!settingStatus) {
    coolStepActive = (value!=0);
    arduinoPort.write(coolStepActive? "K+\n":"K-\n");
  }
}

void setCurrent(int current) {
  currentSlider.setValue((float)current/1000.0);
}

void setDirection(int direction) {
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

