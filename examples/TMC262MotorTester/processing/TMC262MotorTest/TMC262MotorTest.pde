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
Button runButton;

boolean running = false;

void setup() {
  	size(800,600);
  	controlP5 = new ControlP5(this);
  	// add a vertical slider for speed
  	speedSlider = controlP5.addSlider("speed",1,1000,20,20,50,10,100);
  	//add a button te let the motor run
 	runButton = controlP5.addButton("run", 1,40,50,30,30);

	//configure the serial connection
	// List all the available serial ports:
	println(Serial.list());

	/*  I know that the first port in the serial list on my mac
	is always my  Keyspan adaptor, so I open Serial.list()[0].
	Open whatever port is the one you're using.
	*/
	arduinoPort = new Serial(this, Serial.list()[0], 9600);
  
}

void draw() {
	background(0);	
}
 
void speed(float theSpeed) {
  int speed = (int) theSpeed;
  println("setting speed to "+speed);
  arduinoPort.write("S"+speed+"\n");
}

void run(int theValue) {
  println("button pressed");
  if (running) {
    println("stopping motor");
    arduinoPort.write("s\n");
    running = false;
  } else {
    println("starting motor");
    arduinoPort.write("r\n");
    running = true;
  }
}

