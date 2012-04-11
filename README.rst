Arduino TMC262 Stepper Motor Controller Library
===============================================

License
-------

TMC262Stepper.cpp - - TMC 262 Stepper library for Wiring/Arduino - Version 0.1
 
based on the stepper library by Tom Igoe, et. al.
 
Copyright (c) 2011, Interactive Matter, Marcus Nowotny
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

About
-----

The TMC262 is a stepper motor controller for bipolar stepper motors. From the trinamic web site:

 The TMC262 is the first energy efficient high current high precision microstepping driver 
 IC for bipolar stepper motors. The unique high resolution sensorless load detection stallGuard2™ 
 is used to for the world’s first integrated load dependent current control feature called coolStep™.
 The ability to read out the load and detect an overload makes the TMC262 an optimum choice for 
 drives where a high reliability is desired at a low cost. The new patented spreadCycle PWM mixed 
 decay chopper scheme ensures best zero crossing performance as well as high speed operation. 
 The TMC262 can be driven with Step & Direction signals as well as by serial SPI™ interface. 
 Using the microPlyer allows to operate the motor with highest 256 μStep smoothness reducing the 
 input frequency to 16 μSteps. A full set of protection and diagnostic features makes this device 
 very rugged. It directly drives external MOSFETs for currents of up to 6A. This way it reaches 
 highest energy efficiency and allows driving of a high motor current without cooling measures 
 even at high environment temperatures.


The unique features of the TMC262 are that everything can (and must) be controlled in software:

* the motor current
* microstepping
* stall protetction
* current reduction according to load
* stallGuard2™ sensorless load detection
* coolStep™ load dependent current control
* spreadCycle hysteresis PWM chopper 
* microPlyer 16-to-256 μStep multiplyer
* full protection and diagnostics

This makes the TMC262 a bit harder to use than other stepper motors but much more versatile.
This library resolves all the complicated stuff so that you can use TMC262 straight away.
Furthermore, all the settings are implemented in high level interfaces so that configuring your
motor is a breeze.

How to use
----------

Basic Usage
~~~~~~~~~~~

If you want to directly use the library scroll down for the description of the most important 
features of the library. But the easiest approach is to upload and start the examples of this 
library to get a feeling of the capabilities of this library and your motor.

Installation
~~~~~~~~~~~~

Download the library and copy it into your *libraries* directory of your Arduino Sketch directory.
If this description is to brief for you check out the description on installing contributed
Libraries for Arduino on the Arduino Library Page http://arduino.cc/en/Reference/Libraries

Attach the break out board or shield to your Arduino.

Now you can connect the Motor to your shield or breakout board. Bipolar stepper motors have 4 wires.
2 for each phase. One phase goes to A1 and A2 - the other phase goes to B1 and B2.

If you are unsure which wires belong to which phase you can simlpy check this:
* Make sure none of the wires are connected (i.e. touching each other on the unisolated end).
  You should be able to turn shaft of the motor quite easily with no really noticable steps. It 
  should be considerable smooth.

* Now hold two wires of the motor togehter so that the unisolated wire ends are touching each other.
  Or add a jumper wire to two sockets of your motor connector if it is present.

* Turn the shaft of your motor.
  
* Now exchange one wire to any other of the 2 remaining wires. Turn the shaft of your motor again.

* In one of the combination you should be able to fell a considerable detent or steps. If you do
  so the wires you are holding together are two wires of one phase. The other two wires belong to 
  the other phase.
  
* If the above method does not work for you or your motor has more than two wires you can check it
  with your Ohmmmeter (multimeter measuring the resistance). E.g. unipolar stepper motors have 
  6 wires, but can be used as bipolar stepper motors if you use the correct wires). Check the 
  resistance between each wire combination. You should get the following result: In a lot wire 
  configurations there is no connection. Two wire ends have a reasonyble high resistance (normally
  below 10 Ohms). For unipolar motors you have two wires which have half the resistance to the other
  wires of the same phase (i.e. if there is a connection at all). 
  The wires with the higher resistance compromise one phase. And for unipolar motors the wires with
  half the resistance are the 'common wire'. You don't need those in biploar configuration.
  
Testing the Motor Parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The fastest way to see your motor moving is to use the sketch *TMC262MotorTest* from the examples
directory in the library (File->Examples->TMC262Stepper->TMC262MotorTest in the Arduino menu).

It assumes the following connections for the shield or brakout board:
* The CS Pin on Arduino Pin 8
* The DIR Pin on Arduino Pin 6
* The STEP Pin on Arduino Pin 7
* The ENABLE Pin on Arduino Pin 8 (even though the shield works without that connection)

If this is different for you you have two different ways to react:

* Connect the pins accordingly
* Change the definitions in the TMXC262MotorTester to reflect your conditions.

If you check the content of the example in your library (with your finder, exploerer or whatever 
you call your file browser) you see the that there is a directory *processing*. It contains a 
Processing sketch which acts as host side control program for the motor tester. If you do not
have processing installed on your computer head over to http://processing.org/ to download a copy
for you operating system.

*Attention:* You must have the ControlP5 library installed for processing. Refer to 
http://www.sojamo.de/libraries/controlP5/ for download and details.

*It is planned that once the Processing sketch is a tad more matured ot offer prebuilt binaries for 
various operating systems.* Anyway installing and using Precessing is good for proramming skills
and marvelous fun.

Now upload the motor tester sketch to your Arduino, open the control sketch in Processing, check
that the serial port used in the processing sketch fits your Arduino connection. You are looking
for that line::

  arduinoPort = new Serial(this, Serial.list()[0], 115200);

*This will also get much more convenient in future version.*

Now attach power to your motor (i.e. connect 10-40V to the shield or break out board). Reset the 
Arduino - it configures the motor after boot up - so you should reset it every time you switch on
the motor power. Often this is done automatically by the Processing sketch - but it is better to get 
sure. Now start up the Processing sketch.

If everything goes fine you should see the main window with two tabs 'configure' and 'run'. In most
cases you can use the 'run' tab to play around with the various parameters:

* The 'RUN'  button starts and stops the motor

* The 'FORWARD'/'BACKWARD' knobs control the direction of your motor

* The 'ENABLED' Button can be used to switch on or off the motor driver. If not enabled the otor can 
  be turned freely. If enabled it cannot (or hardly) be turned by hand. If it is different for you
  there is smoething wrong with your motor or pin connections, or power supply, or Arduino.
  
* The 'SPEED' slider let's you select different motor speeds. It of course only has effect if the
  motor is running.
  
* The 'MICROSTEPPING' selection can be used to choose various microsteppings (1 for full step to 256
  for 1/256th stepping). Obey that the maximum achievable motor speed is also determined by your 
  micro stepping. The Arduino is only able togerneate step impulses up to a certain frequency
  
* The 'STALL GUARD TRESHHOLD' slider with it's + and - buttons can be used to fine tune the load
  detection of the motor driver. If the red line is at the top reduce the setting, if it is at the 
  bottom increase it (and keep in mind that the stall guard value - the red lin - changes with 
  various motor speeds and current settings at the same load).
  
* The 'STALL GUARD FILTER' button enables or disables stall guard filtering. If the filter is enabled 
  the value will only be updated at each 4th full step to increase the precision and reduce noise.
  If the filter is disable you will see something more like a read out cloud than a line - which can 
  be useful too.
  
* The 'CURRENT' slider determine the maximum current for driving the motor. It starts at a much to
  low value of 0.5A current for the motor. This is too low for most motors but safe enough for most
  motors. You should not increase it to a higher value than your motor is specified (if you want to
  keep your motor).
  
In the lower window you can see curves for the current motor values:

* The microstepping position in blue. This is not really useful by itself but indicates the 
   microstepping and can be used to analyze how the various values change if you change microstepping
   or according to the current microstepping position
   
* The stall guard readout in red. 

* The current the motor is currently runnning at in yellow. This is an important value if you are
  configuring the cool step configuration.

*The description for the cool step config is currently missing*

The 'configure' tab can be used to fine tune the way the driver supplies the current to the motor. 
For now you unfortunately have to check the datasheet for details.

The Minimal Sketch
~~~~~~~~~~~~~~~~~~

In the TMC262 stepper driver you will find the sketch 'TMC262Example' sketch. This is the bare 
minimun code you need to use the TMC262 stepper driver. You can use this as basis for your code.


Basic Usage
-----------

Initializing the motor driver
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creating a stepper motor driver::
TMC262Stepper tmc262Stepper = TMC262Stepper(200,2,3,4,300);

The settings are:
* the steps per rotation to calulate the speed correctly - here a 200 steps/rotation motor
* the client select pin for SPI - here pin 2
* the direction pin for stepping - here pin 3
* the step pin for stepping - here pin 4
* the RMS current for the motor in Milliamps (mA) - here 300mA

The stepper motor driver must be configured using SPI. So it has to be started::
  tmc262Stepper.start();
  
Setting the speed
~~~~~~~~~~~~~~~~~

The current speed can be set in rotations per minutes with the speed() command::
  tmc262Stepper.setSpeed(300);

Stepping
~~~~~~~~

To step in positive direction you specify the number of steps like this::
    tmc262Stepper.step(6400);

To step in negative direction you can specify the number of steps like this::
    tmc262Stepper.step(-6400);

Microstepping
~~~~~~~~~~~~~
To set the number of microsteps you can use::
    tmc262Stepper.setMicrosteps(32);

The following values are supported:
* 0 for full step
* 2 for half step
* 4 for 1/4th
* 8 for 1/8th
* 16 for 1/16th
* 32 for 1/32th
* 64 for 1/64th
* 128 for 1/128th
* 256 for 1/256th

All values in between are rounded down to the next valid value.

*Micro stepping is not yet considered in the RPM setting - you have to adjust it manually.*

Detailed Configuration
-----------------------

*Currently only the configuration of the constant off time chopper is supported*

Constant Off Time Chopper
~~~~~~~~~~~~~~~~~~~~~~~~~

You can select and configure the constant off timer like it is done for the default values::
	setConstantOffTimeChopper(7, 54, 13,12,1);

* constant_off_time: The off time setting controls the minimum chopper frequency. 
 For most applications an off time within	the range of 5μs to 20μs will fit.
	2...15: off time setting

* blank_time: Selects the comparator blank time. This time needs to safely cover the switching event and the
  duration of the ringing on the sense resistor. For
	0: min. setting 3: max. setting
* fast_decay_time_setting: Fast decay time setting. With CHM=1, these bits control the portion of fast decay for each chopper cycle.
	0: slow decay only
	1...15: duration of fast decay phase
* sine_wave_offset: Sine wave offset. With CHM=1, these bits control the sine wave offset. 
 A positive offset corrects for zero crossing error.
	-3..-1: negative offset 0: no offset 1...12: positive offset
* use_current_comparator: Selects usage of the current comparator for termination of the fast decay cycle. 
 If current comparator is enabled, it terminates the fast decay cycle in case the current 
 reaches a higher negative value than the actual positive value.
	1: enable comparator termination of fast decay cycle
	0: end by time only

Explained in the datasheet like this:

 Both motor coils are operated using a chopper principle. The chopper for both coils works 
 independently of each other. In figure 14 the different phases of a chopper cycles are shown. 
 In the on-phase, the current is actively driven into the coils by connecting them to the power 
 supply in the direction of the target current. A fast decay phase reverses the polarity of the coil 
 voltage to actively reduce the current. The slow decay phase shorts the coil in order to let the 
 current re-circulate. While in principle the current could be regulated using only on phases and 
 fast decay phases, insertion of the slow decay phase is important to reduce current ripple in the 
 motor and electrical losses. The duration of the slow decay phase sets an upper limit to the 
 chopper frequency. The current comparator can measure coil current, when the current flows through 
 the sense resistor. Whenever the coil becomes switched, spikes at the sense resistors occur due to 
 charging and discharging parasitic capacities. During this time (typically one or two microseconds), 
 the current cannot be measured. It needs to be covered by the blank time setting.
 
 The classic constant off time chopper uses a fixed portion of fast decay following each on phase. 
 While the duration of the on time is determined by the chopper comparator, the fast decay time 
 needs to be set by the user in a way, that the current decay is enough for the driver to be able 
 to follow the falling slope of the sine wave, and on the other hand it should not be too long, in 
 order to minimize motor current ripple and power dissipation. This best can be tuned using an 
 oscilloscope or trying out motor smoothness at different velocities. A good starting value is a 
 fast decay time setting similar to the slow decay time setting.

 After tuning of the fast decay time, the offset should be determined, in order to have a smooth 
 zero transition. This is necessary, because the fast decay phase leads to the absolute value of 
 the motor target current + offset current being lower than the target current (see figure 17). 
 If the zero offset is too low, the motor stands still for a short moment during current 
 zero crossing, if it is set too high, it makes a larger microstep. 

 Typically, a positive offset setting is required for optimum operation.
 
Spread Cycle Chopper
~~~~~~~~~~~~~~~~~~~~

If you know your motor parameters well (current, winding resistance and windind inductance) it may
be easier and better to use the spread cycle chopper.
To calculate the values refer to the excel sheet provided by trinamic:
http://trinamic.com/tmc/media/Downloads/integrated_circuits/TMC262/Application_notes/tmc262_calculations.xls

You can use it like::
tmc262Stepper.setSpreadCycleChopper(char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement);

From the datasheet:
 The spreadCycle chopper scheme (pat.fil.) is a precise and simple to use chopper principle, which
 automatically  determines the optimum fast decay portion for the motor. Anyhow, a number of settings
 can be made in order to optimally fit the driver to the motor.
 For most low current drivers, a setting of 1 or 2 is good. For high current applications with 
 large MICOIL SFETs, a setting of 2 or 3 will be required.
 Each chopper cycle is comprised of an on phase, a slow decay phase, a fast decay phase and a 
 second slow decay phase (see figure 15). The slow decay phases limit the maximum chopper 
 frequency and are important for low motor and driver power dissipation. 
 The hysteresis start setting limits the chopper frequency by forcing the driver to introduce a 
 minimum amount of current ripple into the motor coils. The motor inductivity determines the 
 ability to follow a changing motor current. The duration of the on- and fast decay phase needs to 
 cover at least the blank time, because the current comparator is disabled during this time. 

Random Off Time
~~~~~~~~~~~~~~~

The random off time can be used to reduce noise and EMI of the motor. You can set it
via::
  tmc262Stepper.setRandomOffTime(1);

A value of 0 disables the random off time. Any other value enables it.

From the datasheet:
 In a constant off time chopper scheme both coil choppers run freely, i.e. are not synchronized. 
 The frequency of each chopper mainly depends on the coil current and the position dependant 
 motor coil inductivity, thus it depends on the microstep position. With some motors a slightly 
 audible beat can occur between the chopper frequencies, especially when they are near to each other. 
 This typically occurs at a few microstep positions within each quarter wave. This effect normally 
 is not audible when compared to mechanical noise generated by ball bearings, etc. Further factors 
 which can cause a similar effect are a poor layout of sense resistor GND connection.
Hint: A common factor, which can cause motor noise, is a bad PCB layout causing coupling of both 
sense resistor voltages.
In order to minimize the effect of a beat between both chopper frequencies, an internal random 
generator is provided. It modulates the slow decay time setting when switched on by the RNDTF bit. 
The RNDTF feature further spreads the chopper spectrum, reducing electromagnetic emission on single 
frequencies.
