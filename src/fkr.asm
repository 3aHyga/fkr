/****************************FKR on ADSP 2185********************************/
#define nx 592
#define ny 291
#define nk 37
#define pause 148 - 10
#define ncams 2

.section/data	framedata;
.VAR	HS = 0;
.VAR	FRAME = 0;
.VAR	ROW = 0;
.VAR	CAM1[1024];
.VAR	CAM2[1024];
.VAR	CAM3[1024];
.VAR	CAM4[1024];

.section/data	bufferdata;
.VAR	BUFFER[nx] = "buffer.dat";


.section/pm	interrupts;	/*------Interrupt vector table------*/
	ICNTL = 0x17;		/* ��������� ������������ ���������� �� �������� */
	RESET FLAG_OUT;
	IMASK = 8;		/* ������������ ���� ���������� ����� ���������� BDMA */
	JUMP start1;
	RTI; nop; nop; nop;	/* 0x0004: IRQ2 */
IRQL1:	AX0 = DM(I6,M4), AR = AX0 + AY1; /* 0x0008: ������ ��������� ���������� ����� (IRQL1) */
	DM(I2,M0) = AR;
	DM(I1,M0) = 0;
	JUMP frame;
IRQL0:	AX0 = DM(I3,M0), AR = AX0 + AY1; /* 0x000C: ������ ��������� ���������� ������ ������ (IRQL0) */
	AY0 = 15;
	DM(I3,M0) = AR, AF = AR - AY0;
	JUMP row;
start1: I0 = 0x3FE1;		/* 0x0010: SPORT0 �������� */
	M1 = 1; 		/* ��������� ������������ M5 � 1 */
	L0 = 0;
	DM(I0,M1) = 0x20;	/* ��������� ������ BIAD � 0x20 */
	DM(I0,M1) = 0x20;	/* 0x0014: SPORT0 ����, ��������� ������ BEAD � 0x20 */
	DM(I0,M1) = 0;		/* ��������� ����������� - ������ � �� �� �� � ������������ ���������� ��������� */
	DM(I0,M1) = eop - 0x20; /* ������ ����������� �� �� � �� */
	JUMP start2;
	RTI; nop; nop; nop;	/* 0x0018: IRQE, �������� � ������� �������� BWCOUNT ���������� ��������� ���� � ������ �������� */
BDMA:	IF NOT FLAG_IN JUMP iret;	 /* 0x001C: BDMA*/
	RESET FLAG_OUT;
	nop;
	JUMP output;
	RTI; nop; nop; nop;	/* 0x0020: ������ ��������� ���������� ������ ������ (INT1) */
	RTI; nop; nop; nop;	/* 0x0024: ������ ��������� ���������� (INT0) */
timer1: DIS TIMER;
	DM(I0,M1) = nx; 	/* 0x0028: ������ ��������� ���������� �� �������, ������ ����� ������� */
	I0 = 0x3FE2;
	JUMP receive;
iret:	RTI;			/* 0x002C: Power down*/
start2:
	IDLE;			/* �������� ���������� ��������� �������� ��������� �� �� */
	DIS INTS;
	M0 = 0; 		/* ��������� ������������ M4 � 0 */


.section/pm program;
start:
	DIS TIMER;		/* ������ ����� ������� */
	DM(I0,M1) = 0x70;	/* ��������� ������ � ������� ��������������� ������ PF6-4 � 1 */
	DM(I0,M1) = 0x2B00;	/* ��������� ������ �������������� ������ �� ���� � ��������� 2-� ������ �������� ��� ������ (+1 ���� �� ������ � ��� �� �������� �� ������� tBDMA) �� �������� ������ �� ������ */
	DM(I0,M0) = 0;		/* ��������� ������� ������ ������ �� ��������� */
	I0 = 0x3FFB;		/* TSCALE = 0x3FFB, TCOUNT = 0x3FFC, TPERIOD = 0x3FFD */
	DM(I0,M1) = 0;		/* ��������� ���������� ������� TSCALE � 1 */
	DM(I0,M1) = pause;	/* ��������� �������� ������� TCOUNT �� ������� �������� �� ����� � ������� 180 ��� */
	DM(I0,M1) = pause;	/* ��������� �������� ������� TPERIOD �� ������� �������� �� ����� � ������� 180 ��� */
	DM(I0,M1) = 0x7FFF;	/* ��������� ������ �������� IO */
	DM(I0,M0) = 7;		/* ��������� ����� SPORT1 �� ����� ���������� IRQ0, IRQ1 */
	I0 = 0x3FF3;		/* ������� ���������� ����������� SPORT0 */
	DM(I0,M0) = 0;		/* ���������� ������ CLKOUT */
	I0 = 0x3FEF;		/* ������� ���������� ����������� SPORT1 */
	DM(I0,M0) = 0;		/* ���������� ������������ Powerdown */
	M4 = 0; 		/* ��������� ������������ M4 � 0 */
	M5 = 1; 		/* ��������� ������������ M5 � 1 */
	IMASK = 0x100;		/* ������������ ���� ���������� ����� ���������� ����� */
	I4 = CAM1;
	L4 = CAM1 + 2;
	I5 = CAM2;
	L5 = CAM2 + 2;
	I6 = CAM3;
	L6 = CAM3 + 2;
	I7 = CAM4;
	L7 = CAM4 + 2;
	I0 = 0x3FE1;
	L0 = 4;
	I1 = HS;
	L1 = 0;
	I2 = FRAME;
	L2 = 0;
	I3 = ROW;
	L3 = 0;
	AY1 = 1;
	DM(I2,M0) = 0;		/* ����� �������� ������ */
	I0 = 0x3FE1;
	DM(I0,M1) = 0x4000;	/* ��������� ������ BIAD � ����� FRAME */
	DM(I0,M1) = 0;		/* ��������� ������ BEAD � 0 */
	DM(I0,M1) = 3;		/* ��������� ������ ������ �� �� � ������ LSB */
	ENA INTS;		/* ���������� ���������� */
loop1:	IDLE; //�������� ���������� �� �������
//	  IF NOT FLAG_IN JUMP loop1;
	// ����� ����� BDMA
//	  I0 = 0x3FE1;
//	  DM(I0,M1) = FRAME;	  /* ��������� ������ BIAD � ����� FRAME */
//	  DM(I0,M1) = 0;	  /* ��������� ������ BEAD � 0 */
//	  DM(I0,M1) = 5;	  /* ��������� ������ ������ � �� � ������������ ������ */
	// ����� ����� IO
//	  RESET FL0;
//	  SET FL0;
//	  CNTR = 16;
//	  DO loopout UNTIL CE;
//loopout: IDLE;
//	  SET FL0;
//	  RESET FLAG_OUT;
	JUMP loop1;


output:





frame:	DM(I3,M0) = 0;
	POP STS;
	IMASK = 0x205;		/* ��������� �������� �������� IMASK �� ����� � ��������������� ���������� ������ ������ � ������� */
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	RTI;


row:	IF LT RTI;
	AY0 = 313;
	AF = AR - AY0;
	IF LT JUMP start_timer;
	AY0 = 327;
	AF = AR - AY0;
	IF LT RTI;
	AY0 = 625;
	AF = AR - AY0;
	IF GE RTI;
start_timer:
	ENA TIMER;
//	  I0 = 0x3FE1;
//	  DM(I0,M1) = 0x4000;	  /* ��������� ������ BIAD � ����� FRAME */
//	  DM(I0,M1) = 0;	  /* ��������� ������ BEAD � 0 */
//	  DM(I0,M1) = 3;	  /* ��������� ������ ������ �� �� � ������ LSB */
//	  CNTR = 8;
//	  L4 = CAM1 + 8;
//	  DO cleardata UNTIL CE;
//cleardata: DM(I4,M5) = 0;
//	  L4 = CAM1 + 2;
	RTI;


receive:
	POP STS;		/* ��������� �������� �������� IMASK �� ����� */
	IMASK = 0x316;		/* ��������������� ���������� IRQ0,1,2,E � ���������� ����� */
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	RTI;


cam1:
	AX1 = DM(I0,M0);
	DM(I4,M5) = AX1;
	RTI;
cam2:
	AX1 = DM(I0,M0);
	DM(I5,M5) = AX1;
	RTI;
cam3:
	AX1 = DM(I0,M0);
	DM(I6,M5) = AX1;
	RTI;
cam4:
	AX1 = DM(I0,M0);
	DM(I7,M5) = AX1;
	RTI;


/*cam1:
	AF = PASS MR0;
	IF EQ JUMP zero_count1;
	POP STS;
	AX1 = IMASK;
	AF = CLRBIT 1 OF AX1;
	IMASK = AX1;
	PUSH STS;
	RTI;
zero_count1:
	AX1 = DM(I0,M0), AR = MR0 + AY1;
	DM(I4,M5) = AX1;
	MR0 = AR;
	RTI;*/


eop: