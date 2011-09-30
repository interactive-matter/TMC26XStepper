/*
 TMC262Stepper.cpp - - TMC262 Stepper library for Wiring/Arduino - Version 0.1
 
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

 */


// ensure this library description is only included once
#ifndef TMC262Stepper_h
#define TMC262Stepper_h

#define TMC262_OVERTEMPERATURE_PREWARING 1
#define TMC262_OVERTEMPERATURE_SHUTDOWN 2

// library interface description
class TMC262Stepper {
  public:
    // constructors:
	TMC262Stepper(int number_of_steps, int cs_pin, int dir_pin, int step_pin, unsigned int rms_current);
	
	void start();

    // speed setter method:
    void setSpeed(long whatSpeed);

	//set the number of microsteps per step - up to 256 in 2^i stepping is supported
	void setMicrosteps(int number_of_steps);
	//get the effective number of microsteps
	int getMicrosteps(void);
	
    // mover method:
    void step(int number_of_steps);
	// configure the constant off timer
	void setConstantOffTimeChopper(char constant_off_time, char blank_time, char fast_decay_time_setting, char sine_wave_offset, unsigned char use_current_comparator);
	// or configure with the spread cycle chopper
	void setSpreadCycleChopper(char constant_off_time, char blank_time, char hysteresis_start, char hysteresis_end, char hysteresis_decrement);
	//use random off time for noise reduction
	void setRandomOffTime(char value);
	//set the current in mA
	void setCurrent(unsigned int current);
	//manually read out the status register
	void readStatus(void);
	//is there a stall guard warning?
	//false if no status is known
	boolean isStallGuardOverTreshold(void);
	//return over temperature status 
	//TMC_262_OVER_TEMPERATURE_PREWARING if status is reached, 
	//TMC_262_OVER_TEMPERATURE_SHUTDOWN is the chip is shutdown,
	//-1 if no status is known
	char getOverTemperature(void);
	//is motor channel A shorted to ground
	boolean isShortToGroundA(void);
	//is motor channel B shorted to ground
	boolean isShortToGroundB(void);
	//is motor channel A connected
	boolean isOpenLoadA(void);
	//is motor channel B connected
	boolean isOpenLoadB(void);
	//is chopper inactive since 2^20 clock cycles - defaults to ~0,08s
	boolean isStandStill(void);
	//is the stall guard level reached
	boolean isStallGuardReached(void);
	//reads the stall guard setting from last status
	//returns -1 if stallguard inforamtion is not present
	int getCurrentStallGuardReading(void);
	//library version
    int version(void);

  private:    
    int direction;        // Direction of rotation
    int speed;          // Speed in RPMs
    unsigned long step_delay;    // delay between steps, in ms, based on speed
    int number_of_steps;      // total number of steps this motor can take
        
    long last_step_time;      // time stamp in ms of when the last step was taken
	
	//driver control register copies to easily set & modify the registers
	unsigned long driver_control_register_value;
	unsigned long chopper_config_register;
	unsigned long cool_step_register_value;
	unsigned long stall_guard2_current_register_value;
	unsigned long driver_configuration;
	//the driver status result
	unsigned long driver_status_result;
	
	int getReadoutValue();
	
	//the pins for the stepper driver
	int cs_pin;
	int step_pin;
	int dir_pin;
	
	//status values 
	unsigned char current_scaling; //the current current scaling
	char started; //if the stepper has been started yet
	int microsteps; //the current number of micro steps
	
	//SPI sender
	inline void send262(unsigned long datagram);
};

#endif

