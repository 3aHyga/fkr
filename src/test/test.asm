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
    __hirq2:
	jump frame;
	rti; nop; nop;
    __hirql1:
	rti; nop; nop; nop;
    __hirql0:
	rti; nop; nop; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
    __hirqe:
	rti; nop; nop; nop;
	rti; nop; nop; nop;
    __hirq1:
	rti; nop; nop; nop;
    __hirq0:
	rti; nop; nop; nop;
    __timer:
	rti; nop; nop; nop;
	rti; nop; nop; nop;
.section/pm program;
start:
	ax0 = 10;
	dm(0) = ax0;
	dis ints;
	ax0=0x1807;
	dm(0x3fff)=ax0;
	icntl=0x17;
	imask=IRQ2; //IFRAME
//	  imask=IFRAME | IROW | IDATA1 | IDATA3;
	ena ints;
loop1:	idle;
	jump loop1;

frame:
	ax0 = dm(0);
	ar = ax0 - 1;
	if ne jump frame_rti;
	ax0 = 10;
	dm(0) = ax0;
	RESET FL2, RESET FLAG_OUT;
	SET FL2, SET FLAG_OUT;
	rti;
frame_rti:
	dm(0) = ar;
	RESET FL0, RESET FL1;
	SET FL0, SET FL1;
	rti;


eop:
