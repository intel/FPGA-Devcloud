#include <stdio.h>
#include "sys/alt_stdio.h"
#include "altera_avalon_pio_regs.h" // include for reg32 avalon interfaces
#include "system.h"		// includes all register addresses for components on Nios II system
#include "sqrt_csr.h" // This header file describes the CSR Slave for the sqrt component

// floorsqrt returns an integer squareroot
// If the input is not a perfect square, it will return an answer that's nearest integer rounded towards the lesser value.
int floorsqrt(int input);


int main() {
	alt_putstr("Hello from Nios!\n\n");

	int i, random_number;

	 printf("Ten random squareroot calculations in [1,1000000]\n\n");

	 for (i = 1; i <= 10; i++) {
	   random_number = rand() % 1000000 + 1;
	   printf("floorsqrt(%d): %d\n", random_number, floorsqrt(random_number));
	 }

	// loop does not terminate
	while(1){};

	return 0;
}

int floorsqrt(int input){
	int returnvalue = 0;
	// reading done status from sqrt interrupt status
	int done = 2 & IORD_ALTERA_AVALON_PIO_DATA(SQRT_0_SQRT_INTERNAL_INST_BASE+SQRT_CSR_INTERRUPT_STATUS_REG);

	// pass squareroot argument to hls component (input)
	IOWR_ALTERA_AVALON_PIO_DATA(SQRT_0_SQRT_INTERNAL_INST_BASE+SQRT_CSR_ARG_X_REG,
			input & SQRT_CSR_ARG_X_MASK);
	// send start signal to hls component
	IOWR_ALTERA_AVALON_PIO_DATA(SQRT_0_SQRT_INTERNAL_INST_BASE+SQRT_CSR_START_REG, 1);

	// check if hls component is done and not busy
	do{
		done = 2 & IORD_ALTERA_AVALON_PIO_DATA(SQRT_0_SQRT_INTERNAL_INST_BASE+SQRT_CSR_INTERRUPT_STATUS_REG);
	}while(!done);

	// set the return value
	returnvalue = IORD_ALTERA_AVALON_PIO_DATA((SQRT_0_SQRT_INTERNAL_INST_BASE+SQRT_CSR_RETURNDATA_REG)&SQRT_CSR_RETURNDATA_MASK);


	// reset the floorsqrt component by writing 1 to the interrupt status reg
	IOWR_ALTERA_AVALON_PIO_DATA(SQRT_0_SQRT_INTERNAL_INST_BASE+SQRT_CSR_INTERRUPT_STATUS_REG, 1);

	return returnvalue;
}
