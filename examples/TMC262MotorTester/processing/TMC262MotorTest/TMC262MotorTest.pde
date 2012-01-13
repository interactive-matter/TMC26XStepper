/**
 * ControlP5 Slider. Horizontal and vertical sliders, 
 * with and without tick marks and snap-to-tick.
 * by andreas schlegel, 2010
 */

import controlP5.*;
import processing.serial.*;

ControlP5 controlP5;

Serial arduinoPort;

Slider speedSlider;
Slider sgtSlider;
Toggle runToggle;
RadioButton microsteppingButtons;
boolean settingStatus=false;

boolean running = false;

void setup() {
  size(1000, 800);
  controlP5 = new ControlP5(this);
  //add a button te let the motor run
  runToggle = controlP5.addToggle("run", false, 20, 20, 25, 25);
  // add a vertical slider for speed  
  speedSlider = controlP5.addSlider("speed", 1, 100, 75, 75, 20, 20, 110);
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
  sgtSlider = controlP5.addSlider("stallguardtreshold", -64, 63, 0, 250, 20, 20, 80);

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


