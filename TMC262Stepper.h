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

    // mover method:
    void step(int number_of_steps);

    int version(void);

  private:    
    int direction;        // Direction of rotation
    int speed;          // Speed in RPMs
    unsigned long step_delay;    // delay between steps, in ms, based on speed
    int number_of_steps;      // total number of steps this motor can take
        
    long last_step_time;      // time stamp in ms of when the last step was taken
	
	//the pins for the stepper driver
	int cs_pin;
	int step_pin;
	int dir_pin;
	
	unsigned char current_scaling;
	
	//SPI sender
	unsigned long send262(unsigned long datagram);
};

#endif

