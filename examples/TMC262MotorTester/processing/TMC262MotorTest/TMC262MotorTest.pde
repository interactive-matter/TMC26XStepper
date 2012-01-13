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

Slider speedSlider;
Toggle runToggle;
RadioButton directionButtons;
RadioButton microsteppingButtons;
Slider sgtSlider;
Button sgtPlus;
Button sgtMinus;
Toggle sgFilterToggle;

boolean settingStatus=false;

boolean running = false;


void setup() {
  size(1000, 800);
  //load the font
  controlP5 = new ControlP5(this);
  //configuring the general UI l&f
  //controlP5.getControlFont().setSize(10); - the font is too small, try to increase it!
  //add a button te let the motor run
  runToggle = controlP5.addToggle("run", false, 20, 20, 30, 30);
  //add some directions buttons
  directionButtons = controlP5.addRadioButton("direction",20,70);
  directionButtons.addItem("forward",1);
  directionButtons.addItem("backward",-1);
  directionButtons.activate(0);
  // add a vertical slider for speed  
  speedSlider = controlP5.addSlider("speed", 1, 100, 10, 85, 20, 20, 210);
  //ad a multilist for the microstepping setting
  microsteppingButtons = controlP5.addRadioButton("microstepping", 150, 20);
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
  // add a vertical slider for stallGuard treshold  
  sgtSlider = controlP5.addSlider("stallguardtreshold", -64, 63, 0, 250, 20, 20, 150);
  sgtSlider.setSliderMode(Slider.FIX);
  sgtSlider.setCaptionLabel("Stall Guard Treshold");
  sgtPlus = controlP5.addButton("sgtplus",0,300,20,20,20);
  sgtPlus.setCaptionLabel("+");
  sgtMinus = controlP5.addButton("sgtminus",1,300,50,20,20);
  sgtMinus.setCaptionLabel("-");
  //ading some buttons to have finer sg control
  //adding a button for the filter
  sgFilterToggle = controlP5.addToggle("sgfilter", false, 250, 200, 30, 30);
  sgFilterToggle.setCaptionLabel("Stall GuardFilter");
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


