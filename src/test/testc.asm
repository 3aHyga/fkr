/************2181 Vector Add Example************/

#define n 10
#define z_out 0x100

.section/dm data1;				   /*------Interrupt vector table------*/
.VAR k = 0;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset:
	imask=0x8;
	ENA INTS;
	RESET FL0, RESET FL1, RESET FL2, RESET FLAG_OUT;
	i0=0x3fe1;

	m1=1;
	l0=0;
	dm(i0,m1)=0x20;
	dm(i0,m1)=0x20;

	dm(i0,m1)=0;
	dm(i0,m1)=0x18;
//	  dm(i0,m1)=eop-start+0x10;
	idle;
	SET FL0;

	JUMP start;
	rti; nop; nop;

	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	SET FL1;
	rti; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti;
.section/pm program;
start:
loop1:	JUMP loop1;
eop:
