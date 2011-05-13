#include "WProgram.h"
#include <SPI.h>
#include "TMC262Stepper.h"

#define DEBUG
# define MRES 0

TMC262Stepper::TMC262Stepper(int number_of_steps, int cs_pin, int dir_pin, int step_pin, unsigned int max_current)
{
	//save the pins for later use
	this->cs_pin=cs_pin;
	this->dir_pin=dir_pin;
	this->step_pin = step_pin;
	//calculate the current scaling from the max current setting (in mA)
	float mASetting = max_current;
	//this is derrived from I=(cs+1)/32*Vfs/Rsense*1/sqrt(2)
	//with vfs=5/16, Rsense=0,15
	//giving the formula CS=(ImA*32/(1000*k)-1 where k=Vfs/Rsense*1/sqrt(2) - too lazy to deal with complete formulas
	this->current_scaling = (byte)((mASetting*0.0217223203180507)-0.5); //theoretically - 1.0 for better rounding it is 0.5
}

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
	
	
	SPI.setBitOrder(MSBFIRST);
	SPI.setClockDivider(SPI_CLOCK_DIV8);
	SPI.setDataMode(SPI_MODE0);
	SPI.begin();
		
	send262(0x00000|MRES); 
	send262(0x941D7);
	send262(0xA0000);
	send262(0xD0000|current_scaling);
	send262(0xEF000);
	
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
	  delay(20);
	  digitalWrite(step_pin, LOW);
	  digitalWrite(dir_pin, LOW);
    }
  }
}

/*
  version() returns the version of the library:
*/
int TMC262Stepper::version(void)
{
  return 1;
}

unsigned long TMC262Stepper::send262(unsigned long datagram) {
	unsigned long i_datagram;
	
#ifdef DEBUG
	Serial.print("Sending ");
	Serial.println(datagram,HEX);
#endif

	digitalWrite(cs_pin,LOW);
	
	i_datagram = SPI.transfer((datagram >> 16) & 0xff);
	i_datagram <<= 8;
	i_datagram |= SPI.transfer((datagram >>  8) & 0xff);
	i_datagram <<= 8;
	i_datagram |= SPI.transfer((datagram      ) & 0xff);
	i_datagram >>= 4;
	
	digitalWrite(cs_pin,HIGH); 
#ifdef DEBUG
	Serial.print("Received ");
	Serial.println(i_datagram,HEX);
#endif
	
	return i_datagram;
}
