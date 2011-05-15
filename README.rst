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


The unique features of the TMC262 are that everything ca (and must) be controlled in software:

* the motor current
* microstepping
* stall protetction
* current reduction according to load
* stallGuard2™ sensorless load detection
* coolStep™ load dependent current control
* spreadCycle hysteresis PWM chopper 
* microPlyer 16-to-256 μStep multiplyer
* full protection and diagnostics

This makes the TMC262 a bit harder to use than other stepper motor but much more versatile.
This library resolves all the complicated stuff so taht you can use TMC262 straight away.
Furthermore all the settings are implemented in high level interfaces so that configuring your
motor is a breeze.

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

