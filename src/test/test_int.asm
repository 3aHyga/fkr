/************2181 Vector Add Example************/

#define ITIMER 0x1
#define IRQ0   0x2
#define IRQ1   0x4
#define IRQ2   0x200
#define IRQE   0x10
#define IRQL0  0x80
#define IRQL1  0x100

#define IFRAME IRQ2
#define IROW   IRQE
#define IDATA1 IRQ0
#define IDATA2 IRQ1
#define IDATA3 IRQL0
#define IDATA4 IRQL1



.section/pm boot1;
	DIS INTS;
//	  RESET FL0, RESET FL1, RESET FL2, RESET FLAG_OUT;
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
	jump start;
	rti; nop; nop;
	RESET FL0, RESET FL1;
	SET FL0, SET FL1;
	rti; nop;
	rti;
	nop; nop; nop;
	jump pix2;
	nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	RESET FL2, RESET FLAG_OUT;
	SET FL2, SET FLAG_OUT;
	rti; nop;
	rti; nop; nop; nop;
	rti;
	nop; nop; nop;
	jump pix1;
	nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
.section/pm program;
start:
	dis ints;
	icntl=0x17;
	imask=0;
//	  imask=IROW;
//	  imask=IFRAME | IROW | IDATA1 | IDATA3;
	ax0=0x1807;
	dm(0x3fff)=ax0;
	ax0=0x7f0c;
	dm(0x3fe6)=ax0;
	i0=0x3fe5;
	l0=0;
	m0=0;
	ax0=0;
	ena ints;
	jump test;
loop1:	idle;
	jump loop1;

pix1:
	dm(i0,m0)=ax0;
	ar = setbit 2 of ax0;
	dm(i0,m0)=ar;
	rti;
pix2:
	dm(i0,m0)=ax0;
	ar = setbit 3 of ax0;
	dm(i0,m0)=ar;
	rti;

test:
	imask=0;
	ax0=0x1807;
	dm(0x3fff)=ax0;
	ax0=0xff3f;
	dm(0x3fe6)=ax0;
loop11:
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
loop_stop: idle;
	jump loop_stop;
eop:
