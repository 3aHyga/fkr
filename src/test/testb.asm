/************2181 Vector Add Example************/

#define n 10
#define z_out 0x100

.section/dm data1;				   /*------Interrupt vector table------*/
.VAR k = 0;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset:
	imask=0x0;
	ENA INTS;
	RESET FL0, RESET FL1, RESET FL2, RESET FLAG_OUT;
loop1:	jump loop1;
.section/pm program;
start:	nop;
eop:
