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
.VAR	CAM1[3] = { 0, 0, 0 };
.VAR	CAM2[3] = { 0, 0, 0 };

.section/data	bufferdata;
.VAR	BUFFER[nx] = "buffer.dat";


.section/pm	interrupts;	/*------Interrupt vector table------*/
	ICNTL = 0x17;		/* ��������� ������������ ���������� �� �������� */
	IMASK = 8;		/* ������������ ���� ���������� ����� ���������� BDMA */
	DIS TIMER;		/* ������ ����� ������� */
	JUMP start1;
	AX0 = DM(I6,M4), AR = AX0 + AY1; /* 0x0004: ������ ��������� ���������� ����� (IRQ2) */
	DM(I6,M4) = AR;
	DM(I7,M4) = 0;
	JUMP frame;
start1: I0 = 0x3FE1;		/* 0x0008: IRQL1*/
	M1 = 1; 		/* ��������� ������������ M5 � 1 */
	L0 = 0;
	DM(I0,M1) = 0x20;	/* ��������� ������ BIAD � 0x20 */
	DM(I0,M1) = 0x20;	/* 0x000C: IRQL0, ��������� ������ BEAD � 0x20 */
	DM(I0,M1) = 0;		/* ��������� ����������� - ������ � �� �� �� � ������������ ���������� ��������� */
	DM(I0,M1) = eop - 0x20; /* ������ ����������� �� �� � �� */
	IDLE;			/* 0x0010: SPORT0 ��������, �������� ���������� ��������� �������� ��������� �� �� */
	DIS INTS;
	JUMP start;
	nop;
	RTI; nop; nop; nop;	/* 0x0014: SPORT0 ���� */
	DM(I6,M4) = 8;		/* 0x0018: IRQE, �������� � ������� �������� BWCOUNT ���������� ��������� ���� � ������ �������� */
	CNTR = 128;
	DO waitloop UNTIL CE;
waitloop: NOP;
	RTI; nop; nop; nop;	/* 0x001C: BDMA*/
	ENA TIMER;		/* 0x0020: ������ ��������� ���������� ������ ������ (INT1), ���������� ����� ������� */
	AX0 = DM(I7,M4), AR = AX0 + AY1; /* 0x0020: ������ ��������� ���������� ������ ������ (INT1), ���������� ����� ������� */
	AY0 = 15;
	DM(I7,M4) = AR, AF = AR - AY0;
	JUMP row;
	RTI;			/* 0x0024: ������ ��������� ���������� (INT0) */
	nop; nop; nop;
	DIS TIMER;		/* 0x0028: ������ ��������� ���������� �� �������, ������ ����� ������� */
	DM(I0,M1) = 3;		/* ��������� ������ ������ �� �� � ������ ��� */
	DM(I0,M0) = nx; 	/* �������� � ������� �������� BWCOUNT ���������� ��������� ���� � ������ �������� */
	JUMP timer_p;
	RTI; nop; nop; nop;	/* 0x002C: Power down*/


.section/pm program;
start:	M0 = 0; 		/* ��������� ������������ M4 � 0 */
	DM(I0,M1) = 0x70;	/* ��������� ������ � ������� ��������������� ������ PF6-4 � 1 */
	DM(I0,M1) = 0x2B00;	/* ��������� ������ �������������� ������ �� ���� � ��������� 2-� ������ �������� ��� ������ (+1 ���� �� ������ � ��� �� �������� �� ������� tBDMA) �� �������� ������ �� ������ */
	DM(I0,M0) = 0;		/* ��������� ������� ������ ������ �� ��������� */
	I0 = 0x3FFB;		/* TSCALE = 0x3FFB, TCOUNT = 0x3FFC, TPERIOD = 0x3FFD */
	DM(I0,M1) = 0;		/* ��������� ���������� ������� TSCALE � 1 */
	DM(I0,M1) = pause;
	DM(I0,M1) = pause;	/* ��������� �������� ������� TPERIOD �� ������� �������� �� ����� � ������� 180 ��. */
	DM(I0,M1) = 0x7FFF;	/* ��������� ������ �������� IO */
	DM(I0,M0) = 7;		/* ��������� ����� SPORT1 �� ����� ���������� IRQ0, IRQ1 */
	I0 = 0x3FF3;		/* ������� ���������� ����������� SPORT0 */
	DM(I0,M0) = 0;		/* ���������� ������ CLKOUT */
	I0 = 0x3FEF;		/* ������� ���������� ����������� SPORT1 */
	DM(I0,M0) = 0;		/* ���������� ������������ Powerdown */
	M4 = 0; 		/* ��������� ������������ M0 � 0 */
	M5 = 1; 		/* ��������� ������������ M1 � 1 */
	IMASK = 0x200;		/* ������������ ���� ���������� ����� ���������� ����� */
	I4 = BUFFER;		/* �������� �������� ������ I4 � ������ ������ ������ �������� �������� */
	I5 = 0x1000;
	I6 = FRAME;		/* ��������� �������� ������ I6 � ������ ������ ������ ����� */
	I7 = ROW;
	I0 = 0x3FE1;
	I1 = HS;
	L4 = BUFFER + nx;
	L5 = 0x1000 + nx * ny / 16;
	L6 = 0;
	L7 = 0;
	L0 = 4;
	L1 = 0;
	AY1 = 1;
	DM(I6,M4) = 0;		/* ����� �������� ������ */
	SE = 2; 		/* ��������� ����������� � ���������� ������� - ����� �� 2 ������� */
	RESET FLAG_OUT;
	ENA INTS;		/* ���������� ���������� */
//	  AX0 = 1;
//	  CNTR = 8; // nx * ny / ((nx * k / 8) * 8)
loop1:	IDLE; //�������� ���������� �� �������
	IF NOT FLAG_IN JUMP loop1;
start_performing:
	IMASK = 0x10;
	SE = -1;		 /* ��������� ����������� � ���������� ������� - ������ �� 1 ������ */
	I2 = CAM1 + 2;
	I3 = CAM2 + 2;
	L2 = CAM1 + 3;
	L3 = CAM2 + 3;
	CNTR = ny;
	DO loopny UNTIL CE;
	CNTR = ny;
	AX0 = 0;
	AX1 = 0;
	MR0 = 0;
	MR1 = 0;
	DO loopny UNTIL CE;
	CNTR = nx;
	DO loopnx UNTIL CE;
	AR = DM(I2,M0), AR = AR - AY1;
	IF EQ JUMP second_cam;
	AF = TSTBIT 0 OF MR2;
	IF NE JUMP first1;
	AF = PASS AX1;
	IF NE JUMP first1_stopcnt;
	AR = AX0 + AY1, AX0 = AR;
	JUMP second_cam;
first1:
	AR = AX1 + AY1, AX1 = AR;
	JUMP second_cam;
first1_stopcnt:
	AR = DM(I2,M0), AR = AR + AY1;
	DM(I2,M0) = AR;
second_cam:
	SR = ASHIFT MR2 (LO);
	AR = DM(I3,M0), AR = AR - AY1;
	IF EQ JUMP loop8_exit;
	AF = TSTBIT 0 OF MR2;
	IF NE JUMP second1;
	AF = PASS MR1;
	IF NE JUMP second1_stopcnt;
	AR = MR0 + AY1, MR0 = AR;
	JUMP loop8_exit;
second1:
	AR = MR1 + AY1, MR1 = AR;
	JUMP loop8_exit;
second1_stopcnt:
	AR = DM(I3,M0), AR = AR + AY1;
	DM(I3,M0) = AR;
loopnx:
	DM(I2,M1) = AX0;
	DM(I2,M1) = AX1;
	DM(I2,M1) = 0;
	DM(I3,M1) = MR0;
	DM(I3,M1) = MR1;
	DM(I3,M1) = 0;
	// ����� ����� BDMA
	DM(I0,M5) = FRAME;	/* ��������� ������ BIAD � ����� FRAME */
	DM(I0,M5) = 0;		/* ��������� ������ BEAD � 0 */
	DM(I0,M5) = 5;		/* ��������� ������ ������ � �� � ������������ ������ */
	// ����� ����� IO
	RESET FL0;
//	  SET FL0;
//	  CNTR = 16;
//	  DO loopout UNTIL CE;
//loopout: IDLE;
//loopny:  NOP;
loopny: SET FL0;	     /* ��������� �������� ������ I6 � ������ ������ ������ ����� */
	I6 = FRAME;
	SE = 2; 		/* ��������� ����������� � ���������� ������� - ����� �� 2 ������� */
	RESET FLAG_OUT;
	JUMP loop1;


frame:	DM(I1,M0) = 0;
	POP STS;
	IMASK = 0x205;		/* ��������� �������� �������� IMASK �� ����� � ��������������� ���������� ������ ������ � ������� */
//	  IMASK = 0x207;	  /* ��������� �������� �������� IMASK �� ����� � ��������������� ���������� ������ ������ */
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	RTI;


/*out_data:
	IF FLAG_IN JUMP output_shift;
	MR0 = DM(I6,M5);
	IO(0) = MR0;
	SET FLAG_OUT;
	JUMP output_exit;
output_shift:
	SR = ASHIFT MR0 BY -8 (LO);
	IO(0) = SR0;
	RESET FLAG_OUT;
output_exit: RTI;*/


row:	IF LT RTI;
	AY0 = 313;
	AF = AR - AY0;
	IF LT JUMP start_timer;
	AY0 = 314;
	AF = AR - AY0;
	IF GE RTI;
	RTI;

start_timer:
	ENA TIMER;
	DM(I0,M1) = BUFFER;	/* ��������� ����� �������� BUFFER ��� ����� �������� �������� BIAD �  */
	DM(I0,M1) = 0x2000;	/* ��������� ������ �������� �������� BEAD � 0x2000 */
	RTI;



eop: