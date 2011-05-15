/*
 TMC262Stepper.cpp - - TLC 262 Stepper library for Wiring/Arduino - Version 0.1
 
 based on the stepper library by Tom Igoe, et. al.
 
 
 */


// ensure this library description is only included once
#ifndef TMC262Stepper_h
#define TMC262Stepper_h

// library interface description
class TMC262Stepper {
  public:
    // constructors:
	TMC262Stepper(int number_of_steps, int cs_pin, int dir_pin, int step_pin, unsigned int max_current);
	
	void start();

    // speed setter method:
    void setSpeed(long whatSpeed);

	//set the number of microsteps per step - up to 256 in 2^i stepping is supported
	void setMicrosteps(int number_of_steps);
	//get the effective number of microsteps
	int getMicrosteps(void);
	
    // mover method:
    void step(int number_of_steps);

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
	
	//the pins for the stepper driver
	int cs_pin;
	int step_pin;
	int dir_pin;
	
	//status values 
	char started; //if the stepper has been started yet
	int microsteps; //the current number of micro steps
	unsigned char current_scaling; //the current current scaling value (for debug) - TODO remove
	
	//SPI sender
	inline unsigned long send262(unsigned long datagram);
};

#endif

