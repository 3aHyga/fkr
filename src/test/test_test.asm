/************2181 Vector Add Example************/

#define n 10
#define z_out 0x100

.section/dm data1;				   /*------Interrupt vector table------*/
.VAR k = 0;

.section/pm boot1;
	imask=0;
	RESET FL0, RESET FL1, RESET FL2, RESET FLAG_OUT;
	i0=0x3fe1;
	m1=1;
	l0=0;
	dm(i0,m1)=0x0;
	dm(i0,m1)=0x60;
	dm(i0,m1)=8;
	dm(i0,m1)=(eop-__reset) * 3;
	idle;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset:
	DIS INTS;
	SET FL0;
	idle;
	ax0=0x1807;
	dm(0x3fff)=ax0;
	ax0=0xff3f;
	dm(0x3fe6)=ax0;
loop1:
	cntr=5125;
	do loop4 until ce;
	RESET FL0, RESET FL1, RESET FL2, RESET FLAG_OUT;
	ax0=0x0000;
	dm(0x3fe5)=ax0;
	cntr=16384;
	do loop2 until ce;
loop2:	nop;
	SET FL0, SET FL1, SET FL2, SET FLAG_OUT;
	ax0=0x00ff;
	dm(0x3fe5)=ax0;
	cntr=16384;
	do loop3 until ce;
loop3:	nop;
loop4:	io(0)=ax0;
	idle;
	jump loop1;

	rti; nop; nop; nop;
	SET FL0;
	rti; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
.section/pm program;
start:
	idle;
	jump start;
eop:
