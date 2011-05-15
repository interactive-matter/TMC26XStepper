#include "WProgram.h"
#include <SPI.h>
#include "TMC262Stepper.h"

//TMC262 register definitions
#define DRIVER_CONTROL_REGISTER 0x0ul
#define CHOPPER_CONFIG_REGISTER 0x80000ul
#define COOL_STEP_REGISTER  0xA0000ul
#define STALL_GUARD2_LOAD_MEASURE_REGISTER 0xC0000ul
#define DRIVER_CONFIG_REGISTER 0xE0000ul

#define REGISTER_BIT_PATTERN 0xFFFFFul

//definitions for the driver control register
#define MICROSTEPPING_PATTERN 0xFul
#define STEP_INTERPOLATION 0x200ul
#define DOUBLE_EDGE_STEP 0x100ul

//definitions for the chopper config register
#define CHOPPER_MODE_STANDARD 0x0ul
#define CHOPPER_MODE_T_OFF_FAST_DECAY 0x4000ul

#define RANDOM_TOFF_TIME 0x200ul
#define BLANK_TIMING_PATTERN 0x1E000
#define BLANK_TIMING_SHIFT 15
#define HYSTERESIS_DECREMENT_PATTERN 0x1800ul
#define HYSTERESIS_DECREMENT_SHIFT 11
#define HYSTERESIS_LOW_VALUE_PATTERN 0x780ul
#define HYSTERESIS_LOW_SHIFT 7
#define HYSTERESIS_START_VALUE_PATTERN 0x70ul
#define HYSTERESIS_START_VALUE_SHIFT 4
#define T_OFF_TIMING_PATERN 0xFul

//definitions for cool step register
#define MINIMUM_CURRENT_FOURTH 0x8000ul
#define CURRENT_DOWN_STEP_SPEED_PATTERN 0x6000ul
#define SE_MAX_PATTERN 0xF00ul
#define SE_CURRENT_STEP_WIDTH_PATTERN 0x60ul
#define SE_MIN_PATTERN 0xful

//definitions for stall guard2 current register
#define STALL_GUARD_FILTER_ENABLE 0x10000ul
#define STALL_GUARD_TRESHHOLD_VALUE_PATTERN 0x7F00ul
#define CURRENT_SCALING_PATTERN 0x1Ful

//default values
#define INITIAL_MICROSTEPPING 0x3ul //32th microstepping

//debuging output
#define DEBUG

/*
 * Constructor
 * number_of_steps - the steps per rotation
 * cs_pin - the SPI client select pin
 * dir_pin - the pin where the direction pin is connected
 * step_pin - the pin where the step pin is connected
 */
TMC262Stepper::TMC262Stepper(int number_of_steps, int cs_pin, int dir_pin, int step_pin, unsigned int max_current)
{
	//we are not started yet
	started=0;
	
	//save the pins for later use
	this->cs_pin=cs_pin;
	this->dir_pin=dir_pin;
	this->step_pin = step_pin;
	//initialize register values
	driver_control_register_value=DRIVER_CONFIG_REGISTER | INITIAL_MICROSTEPPING;
	chopper_config_register=CHOPPER_CONFIG_REGISTER;
	//calculate the current scaling from the max current setting (in mA)
	float mASetting = max_current;
	//this is derrived from I=(cs+1)/32*Vfs/Rsense*1/sqrt(2)
	//with vfs=5/16, Rsense=0,15
	//giving the formula CS=(ImA*32/(1000*k)-1 where k=Vfs/Rsense*1/sqrt(2) - too lazy to deal with complete formulas
	current_scaling = (byte)((mASetting*0.0217223203180507)-0.5); //theoretically - 1.0 for better rounding it is 0.5
	
	//setting the default register values
	driver_control_register_value=DRIVER_CONTROL_REGISTER|INITIAL_MICROSTEPPING;
	microsteps = (1 << INITIAL_MICROSTEPPING);
	chopper_config_register=CHOPPER_CONFIG_REGISTER;
	//ended up in 9C1D7;
	//set to a conservative start value
	setConstantOffTimeChopper(7, 54, 13,12,1);
	cool_step_register_value=COOL_STEP_REGISTER;
	stall_guard2_current_register_value=STALL_GUARD2_LOAD_MEASURE_REGISTER|current_scaling;
	driver_configuration=DRIVER_CONFIG_REGISTER;
}

/*
 * start & configure the stepper driver
 * just must be called.
 */
void TMC262Stepper::start() {

#ifdef DEBUG	
	Serial.println("TMC262 stepper library");
	Serial.print("CS pin: ");
	Serial.println(cs_pin);
	Serial.print("DIR pin: ");
	Serial.println(dir_pin);
	Serial.print("STEP pin: ");
	Serial.println(step_pin);
	Serial.print("current scaling: ");
	Serial.println(current_scaling,DEC);
#endif
	//set the pins as output & its initial value
	pinMode(step_pin, OUTPUT);     
	pinMode(dir_pin, OUTPUT);     
	pinMode(cs_pin, OUTPUT);     
	digitalWrite(step_pin, LOW);     
	digitalWrite(dir_pin, LOW);     
	digitalWrite(cs_pin, HIGH);   
	
	//configure the SPI interface
	SPI.setBitOrder(MSBFIRST);
	SPI.setClockDivider(SPI_CLOCK_DIV8);
	SPI.setDataMode(SPI_MODE0);
	SPI.begin();
		
	//set the initial values
	send262(driver_control_register_value); 
	send262(chopper_config_register);
	send262(cool_step_register_value);
	send262(stall_guard2_current_register_value);
	send262(driver_configuration);
	
	//save that we are in running mode
	started=-1;
	
}

/*
  Sets the speed in revs per minute

*/
void TMC262Stepper::setSpeed(long whatSpeed)
{
  this->step_delay = 60L * 1000L / this->number_of_steps / whatSpeed;
}

/*
  Moves the motor steps_to_move steps.  If the number is negative, 
   the motor moves in the reverse direction.
 */
void TMC262Stepper::step(int steps_to_move)
{  
  int steps_left = abs(steps_to_move);  // how many steps to take
  
  // determine direction based on whether steps_to_mode is + or -:
  if (steps_to_move > 0) {this->direction = 1;}
  if (steps_to_move < 0) {this->direction = 0;}
    
    
  // decrement the number of steps, moving one step each time:
  while(steps_left > 0) {
  // move only if the appropriate delay has passed:
  if (millis() - this->last_step_time >= this->step_delay) {
      // get the timeStamp of when you stepped:
      this->last_step_time = millis();
      // increment or decrement the step number,
      // depending on direction:
      if (this->direction == 1) {
		  digitalWrite(step_pin, HIGH);
      } 
      else { 
		  digitalWrite(dir_pin, HIGH);
		  digitalWrite(step_pin, HIGH);
      }
      // decrement the steps left:
      steps_left--;
	  //disable sthe step & dir pins
	  delay(2);
	  digitalWrite(step_pin, LOW);
	  digitalWrite(dir_pin, LOW);
    }
  }
}

/*
 * Set the number of microsteps per step.
 * 0,2,4,8,16,32,64,128,256 is supported
 * any value in between will be mapped to the next smaller value
 * 0 and 1 set the motor in full step mode
 */
void TMC262Stepper::setMicrosteps(int number_of_steps) {
	long setting_pattern;
	//poor mans log
	if (number_of_steps>=256) {
		setting_pattern=0;
		microsteps=256;
	} else if (number_of_steps>=128) {
		setting_pattern=1;
		microsteps=128;
	} else if (number_of_steps>=64) {
		setting_pattern=2;
		microsteps=64;
	} else if (number_of_steps>=32) {
		setting_pattern=3;
		microsteps=32;
	} else if (number_of_steps>=16) {
		setting_pattern=4;
		microsteps=16;
	} else if (number_of_steps>=8) {
		setting_pattern=5;
		microsteps=8;
	} else if (number_of_steps>=4) {
		setting_pattern=6;
		microsteps=4;
	} else if (number_of_steps>=2) {
		setting_pattern=7;
		microsteps=2;
    //1 and 0 lead to full step
	} else if (number_of_steps<=1) {
		setting_pattern=8;
		microsteps=0;
	}
#ifdef DEBUG
	Serial.print("Microstepping: ");
	Serial.println(microsteps);
#endif
	//delete the old value
	this->driver_control_register_value &=0xFFFF0ul;
	//set the new value
	this->driver_control_register_value |=setting_pattern;
	
	//if started we directly send it to the motor
	if (started) {
		send262(driver_control_register_value);
	}
}

/*
 * returns the effective number of microsteps at the moment
 */
int TMC262Stepper::getMicrosteps(void) {
	return microsteps;
}

/*
 * constant_off_time: The off time setting controls the minimum chopper frequency. 
 * For most applications an off time within	the range of 5μs to 20μs will fit.
 *		2...15: off time setting
 *
 * blank_time: Selects the comparator blank time. This time needs to safely cover the switching event and the
 * duration of the ringing on the sense resistor. For
 *		0: min. setting 3: max. setting
 *
 * fast_decay_time_setting: Fast decay time setting. With CHM=1, these bits control the portion of fast decay for each chopper cycle.
 *		0: slow decay only
 *		1...15: duration of fast decay phase
 *
 * sine_wave_offset: Sine wave offset. With CHM=1, these bits control the sine wave offset. 
 * A positive offset corrects for zero crossing error.
 *		-3..-1: negative offset 0: no offset 1...12: positive offset
 *
 * use_current_comparator: Selects usage of the current comparator for termination of the fast decay cycle. 
 * If current comparator is enabled, it terminates the fast decay cycle in case the current 
 * reaches a higher negative value than the actual positive value.
 *		1: enable comparator termination of fast decay cycle
 *		0: end by time only
 */
void TMC262Stepper::setConstantOffTimeChopper(char constant_off_time, char blank_time, char fast_decay_time_setting, char sine_wave_offset, unsigned char use_current_comparator) {
	//perform some sanity checks
	if (constant_off_time<2) {
		constant_off_time=2;
	} else if (constant_off_time>15) {
		constant_off_time=15;
	}
	char blank_value;
	//calculate the value acc to the clock cycles
	if (blank_time>=54) {
		blank_value=3;
	} else if (blank_time>=36) {
		blank_value=2;
	} else if (blank_time>=24) {
		blank_value=1;
	} else {
		blank_value=0;
	}
	if (fast_decay_time_setting<0) {
		fast_decay_time_setting=0;
	} else if (fast_decay_time_setting>15) {
		fast_decay_time_setting=15;
	}
	if (sine_wave_offset < -3) {
		sine_wave_offset = -3;
	} else if (sine_wave_offset>12) {
		sine_wave_offset = 12;
	}
	//shift the sine_wave_offset
	sine_wave_offset +=3;
	
	//calculate the register setting
	//first of all delete all the values for this
	chopper_config_register &= ~((1<<12) | BLANK_TIMING_PATTERN | HYSTERESIS_DECREMENT_PATTERN | HYSTERESIS_LOW_VALUE_PATTERN | HYSTERESIS_START_VALUE_PATTERN | T_OFF_TIMING_PATERN);
	//set the constant off pattern
	chopper_config_register |= CHOPPER_MODE_T_OFF_FAST_DECAY;
	//set the blank timing value
	chopper_config_register |= (unsigned long)blank_value << BLANK_TIMING_SHIFT;
	//set the fast decay time
	//set msb
	chopper_config_register |= (((unsigned long)(fast_decay_time_setting & 0x8))<<HYSTERESIS_DECREMENT_SHIFT);
	//other bits
	chopper_config_register |= (((unsigned long)(fast_decay_time_setting & 0x7))<<HYSTERESIS_START_VALUE_SHIFT);
	//set the sine wave offset
	chopper_config_register |= (unsigned long)sine_wave_offset << HYSTERESIS_LOW_SHIFT;
	//setting the constant off time
	chopper_config_register |= constant_off_time;
	//using the current comparator?
	if (!use_current_comparator) {
		chopper_config_register |= (1<<12);
	}
	//if started we directly send it to the motor
	if (started) {
		send262(driver_control_register_value);
	}	
}

/*
 version() returns the version of the library:
 */
int TMC262Stepper::version(void)
{
	return 1;
}

/*
 * send register settings to the stepper driver via SPI
 * returns the current status
 */
inline unsigned long TMC262Stepper::send262(unsigned long datagram) {
	unsigned long i_datagram;
	
	//ensure that only valid bist are set (0-19)
	//datagram &=REGISTER_BIT_PATTERN;
	
#ifdef DEBUG
	Serial.print("Sending ");
	Serial.println(datagram,HEX);
#endif
	
	//select the TMC driver
	digitalWrite(cs_pin,LOW);
	
	//write/read the values
	i_datagram = SPI.transfer((datagram >> 16) & 0xff);
	i_datagram <<= 8;
	i_datagram |= SPI.transfer((datagram >>  8) & 0xff);
	i_datagram <<= 8;
	i_datagram |= SPI.transfer((datagram      ) & 0xff);
	i_datagram >>= 4;
	
	//deselect the TMC chip
	digitalWrite(cs_pin,HIGH); 
#ifdef DEBUG
	Serial.print("Received ");
	Serial.println(i_datagram,HEX);
#endif
	
	return i_datagram;
}