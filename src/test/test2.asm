/************2181 Vector Add Example************/

#define n 10
#define z_out 0x100

.section/dm data1;				   /*------Interrupt vector table------*/
.VAR k = 0;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset:
	IO(0) = AX0;
	SET FL0, RESET FL1, SET FL2, RESET FLAG_OUT;
    __loop:
	i0=0x3fe1;
	m1=1;
	l0=0;
	dm(i0,m1)=0;
	dm(i0,m1)=0;
	dm(i0,m1)=3;
	dm(i0,m1)=512;
	AX0 = 0xB55B;
	IO(0) = AX0;
	cntr = 512;
	do kk until ce;
kk:	nop;
	DIS INTS;
	JUMP __loop;


.section/pm program;
start:	nop;
	rti;
	rti;
	rti;
	rti;
	rti;
	rti;
	rti;
	rti;
	rti;
	rti;

