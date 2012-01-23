/**
 * ControlP5 Slider. Horizontal and vertical sliders, 
 * with and without tick marks and snap-to-tick.
 * by andreas schlegel, 2010
 */

import controlP5.*;
import processing.serial.*;

ControlP5 controlP5;

Serial arduinoPort;

//TODO comde up with a nice color scheme
color activeColor = #22aaee;
color foreGroundColor = #1a6699; //Stil to use 1a334c
color labelColor = #f0f0f0;
color valueColor = #f0f0f0;
color graphBackgroundColor = #131313;
color stallGuardColor = #991a1a;
color positionColor = #1a6699; //still to use #8c7f26
color goodStatusColor = labelColor;
color badStatusColor = stallGuardColor;

Slider maxCurrentSlider;

Slider speedSlider;
Toggle runToggle;
RadioButton directionButtons;
RadioButton microsteppingButtons;
Slider sgtSlider;
Button sgtPlus;
Button sgtMinus;
Toggle sgFilterToggle;
Slider currentSlider;

Tab configureTab;
Tab runTab;
Tab activeTab;

boolean settingStatus=false;

boolean running = false;


void setup() {
  size(1000, 800);
  //load the font
  controlP5 = new ControlP5(this);
  runTab = controlP5.addTab("run");
  configureTab=controlP5.getTab("default");
  //customize the tabs a bit
  configureTab.setLabel("configure");
  activeTab = configureTab;
  controlP5.setTabEventsActive(true);
  configureTab.activateEvent(true);
  runTab.activateEvent(true);

  //configuring the general UI l&f
  //the configuration UI
  
  
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
  // add a vertical slider for stallGuard treshold  
  sgtSlider = controlP5.addSlider("stallguardtreshold", -64, 63, 0, 250, 40, 20, 150);
  sgtSlider.setSliderMode(Slider.FIX);
  sgtSlider.setCaptionLabel("Stall Guard Treshold");
  sgtSlider.moveTo(runTab);
  sgtPlus = controlP5.addButton("sgtplus", 0, 300, 40, 20, 20);
  sgtPlus.setCaptionLabel("+");
  sgtPlus.moveTo(runTab);
  sgtMinus = controlP5.addButton("sgtminus", 1, 300, 70, 20, 20);
  sgtMinus.setCaptionLabel("-");
  sgtMinus.moveTo(runTab);
  //ading some buttons to have finer sg control
  //adding a button for the filter
  sgFilterToggle = controlP5.addToggle("sgfilter", false, 250, 220, 30, 30);
  sgFilterToggle.setCaptionLabel("Stall GuardFilter");
  sgFilterToggle.moveTo(runTab);
  
  currentSlider = controlP5.addSlider("current", 0.46, 1.7, 0.4, 950, 50, 20, 210);
  currentSlider.moveTo(runTab);

  //configure the serial connection
  // List all the available serial ports:
  println(Serial.list());

  /*  I know that the first port in the serial list on my mac
   	is always my  Keyspan adaptor, so I open Serial.list()[0].
   	Open whatever port is the one you're using.
   	*/
  arduinoPort = new Serial(this, Serial.list()[0], 115200);
  smooth();
  setupData();
}

void draw() {
  background(graphBackgroundColor);
  drawData();
  decodeSerial();
}

