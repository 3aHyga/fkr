/************2181 Vector Add Example************/

#define n 10
#define z_out 0x100

.section/dm data1;				   /*------Interrupt vector table------*/
.VAR k = 0;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset:
	imask=0x8;
	ENA INTS;
	ax0=0x1807;
	dm(0x3fff)=ax0;

	ax0=0xff3f;
	dm(0x3fe6)=ax0;
	i0=0x3fe1;
	RESET FL0, RESET FL1, RESET FL2, RESET FLAG_OUT;
loop1:
	SET FL1;
	ax0=0x005a;
	dm(0x3fe6)=ax0;
	cntr=512;
	do loop2 until ce;
loop2:	nop;
	RESET FL1;
	ax0=0x00a5;
	dm(0x3fe6)=ax0;
	cntr=512;
	do loop3 until ce;
loop3:	nop;


	rti; nop; nop; nop;
	rti; nop; nop; nop;
	SET FL0;
	rti; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti;
.section/pm program;
start:
	idle;
	jump start;
eop:
