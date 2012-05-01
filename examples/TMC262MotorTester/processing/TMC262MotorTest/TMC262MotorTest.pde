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
color activeColor = #01ADF1;
color foreGroundColor = #01ADF1; 
color uiTextColor = #4D4D4F;
color uiElementColor = #ffffff;
color labelColor = #f0f0f0;
color valueColor = #f0f0f0;
color backgroundColor = #EDEEEF;
color stallGuardColor = #4D4D4F;
color positionColor = #01ADF1;
color goodStatusColor = labelColor;
color badStatusColor = stallGuardColor;
color coolStepColor = #969696;
CColor uiColor = new CColor( foreGroundColor, uiElementColor, activeColor, uiTextColor, uiTextColor);

Tab configureTab;
Tab runTab;
Tab activeTab;

boolean settingStatus=false;

boolean running = false;
int coolStepMin = 0;
int coolStepMax = 0;
boolean coolStepActive = false;

float maxCurrent = 1.7;

List controlElements = new LinkedList();
List serialConfigElements = new LinkedList();

void setup() {
  size(1000, 800);
  //load the font
  controlP5 = new ControlP5(this);
  controlP5.setColor(uiColor);
  runTab = controlP5.getTab("default");
  configureTab =controlP5.addTab("configure"); 
  //customize the tabs a bit
  configureTab.setLabel("configure");
  controlElements.add(configureTab);
  activeTab =  controlP5.getTab("default");
  controlP5.setTabEventsActive(true);
  configureTab.activateEvent(true);
  runTab.activateEvent(true);

  //configuring the general UI l&f
  //the configuration UI

  setupRunConfig();
  setupChooperConfig();
  setupSerialConfig();
  //directly hide the controls again since we are not connected to the Arduino yet
  toggleUi(motor_connected);

  smooth();
  setupData();
}


void toggleUi(boolean show_controls) {
  for (Object c:controlElements) {
    ControllerInterface controller = (ControllerInterface) c;
    if (show_controls) {
      controller.show();
    } else {
      controller.hide();
    }
  }
  for (Object c:serialConfigElements) {
    ControllerInterface controller = (ControllerInterface) c;
    if (show_controls) {
      controller.hide();
    } else {
      controller.show();
    }
  }    
}

void draw() {
  background(backgroundColor);
  drawChopper();
  drawData();
  decodeSerial();
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup() && !settingStatus) {
    if ("microstepping".equals(theEvent.group().name())) { 
      microstepping((int)theEvent.group().value());
    } else 
    if ("direction".equals(theEvent.group().name())) {
      setDirection((int)theEvent.group().value());
    } else if ("decrement".equals(theEvent.group().name())) {
      setHysteresisDecrement((int)theEvent.group().value());
    } else if ("coolStepIncrement".equals(theEvent.group().name())) {
      setCoolStepIncrement((int)theEvent.group().value());
    } else if ("coolStepDecrement".equals(theEvent.group().name())) {
      setCoolStepDecrement((int)theEvent.group().value());
    } else if ("coolStepMin".equals(theEvent.group().name())) {
      setCoolStepMin((int)theEvent.group().value());
    }
  } 
  else if (theEvent.isTab()) {
    activeTab = theEvent.tab();
    println("Tab: "+activeTab.name());
  } 
}

