/****************************FKR on ADSP 2185********************************/
#define nx 592
#define ny 291
#define nk 37
#define pause 148 - 10
#define ncams 4
#define ecams 1
#define camsize 1024

.section/data	framedata;
//.VAR	  MEMADDRBANK = 0;
.VAR	FRAME = 0;
.VAR	ROW = 0;
.VAR	CAM1[camsize];
.VAR	CAM2[camsize];
.VAR	CAM3[camsize];
.VAR	CAM4[camsize];

.section/data	bufferdata;
//.VAR	  BUFFER[nx] = "buffer.dat";


.section/pm	interrupts;	/*------Interrupt vector table------*/
	ICNTL = 0x17;		/* ��������� ������������ ���������� �� �������� */
	DIS TIMER;		/* ������ ����� ������� */
	IMASK = 8;		/* ������������ ���� ���������� ����� ���������� BDMA */
	JUMP start1;
cam3:				/* 0x0004: IRQ2 */
	AX1 = DM(I0,M0);
	DM(I6,M5) = AX1;
	RTI; nop;
	rti; nop; nop; nop;
	rti; nop; nop; nop;
start1: I0 = 0x3FE1;		/* 0x0010: SPORT0 �������� */
	M1 = 1; 		/* ��������� ������������ M5 � 1 */
	L0 = 0;
	nop; nop; nop; nop;
//	  DM(I0,M1) = 0x20;	  /* ��������� ������ BIAD � 0x20 */
//	  DM(I0,M1) = 0x20;	  /* 0x0014: SPORT0 ����, ��������� ������ BEAD � 0x20 */
//	  DM(I0,M1) = 0;	  /* ��������� ����������� - ������ � �� �� �� � ������������ ���������� ��������� */
//	  DM(I0,M1) = eop - 0x20; /* ������ ����������� �� �� � �� */
	JUMP start2;
/*cam4: 			  /* 0x0018: IRQE, �������� � ������� �������� BWCOUNT ���������� ��������� ���� � ������ �������� */
/*	AX1 = DM(I0,M0);
	DM(I7,M5) = AX1;
	RTI; nop;*/
IRQL0:	AX0 = DM(I3,M0); /* 0x000C: ������ ��������� ���������� ������ ������ (IRQL0) */
	AY0 = 15;
	AR = AX0 + AY1, DM(I3,M0) = AR;
	JUMP row;
BDMA:	RESET FL0;		/* 0x001C: BDMA*/
	RTI; nop; nop;
IRQL1:	AX0 = DM(I2,M0);	/* 0x0008: ������ ��������� ���������� ����� (IRQL1) */
	AR = AX0 + AY1, DM(I2,M0) = AR;
	DM(I3,M0) = 0;
	JUMP frame;
//cam2: 			  /* 0x0020: ������ ��������� ���������� ������ ������ (INT1) */
/*	  AX1 = DM(I0,M0);
	DM(I5,M5) = AX1;
	RTI; nop;*/
cam1:				/* 0x0024: ������ ��������� ���������� (INT0) */
	AX1 = DM(I0,M0);
	DM(I4,M5) = AX1;
	RTI; nop;
timer1: DIS TIMER;		/* 0x0028: ������ ��������� ���������� �� �������, ������ ����� ������� */
	DM(I0,M1) = nx;
	I0 = 0x3FE2;
	JUMP receive;
iret:	RTI;			/* 0x002C: Power down*/
start2:
	nop;//IDLE;		      /* �������� ���������� ��������� �������� ��������� �� �� */
	DIS INTS;
	M0 = 0; 		/* ��������� ������������ M4 � 0 */


.section/pm program;
start:
	IFC = 0;
	DM(I0,M1) = 0xF0;	/* ��������� ������ � ������� ��������������� ������ PF6-0 � 1 */
	DM(I0,M1) = 0x2B04;	/* ��������� ������ �������������� ������ �� ���� � ��������� 2-� ������ �������� ��� ������ (+1 ���� �� ������ � ��� �� �������� �� ������� tBDMA) �� �������� ������ �� ������ */
	DM(I0,M0) = 0;		/* ��������� ������� ������ ������ �� ��������� */
	I0 = 0x3FFB;		/* TSCALE = 0x3FFB, TCOUNT = 0x3FFC, TPERIOD = 0x3FFD */
	DM(I0,M1) = 0;		/* ��������� ���������� ������� TSCALE � 1 */
	DM(I0,M1) = pause;	/* ��������� �������� ������� TCOUNT �� ������� �������� �� ����� � ������� 180 ��� */
	DM(I0,M1) = pause;	/* ��������� �������� ������� TPERIOD �� ������� �������� �� ����� � ������� 180 ��� */
	DM(I0,M1) = 0;		/* ��������� ������ �������� IO */
	DM(I0,M0) = 7;		/* ��������� ����� SPORT1 �� ����� ���������� IRQ0, IRQ1 */
	I0 = 0x3FF3;		/* ������� ���������� ����������� SPORT0 */
	DM(I0,M0) = 0;		/* ���������� ������ CLKOUT */
	I0 = 0x3FEF;		/* ������� ���������� ����������� SPORT1 */
	DM(I0,M0) = 0;		/* ���������� ������������ Powerdown */
	M4 = 0; 		/* ��������� ������������ M4 � 0 */
	M5 = 1; 		/* ��������� ������������ M5 � 1 */
//	  IMASK = 0x100;	  /* ������������ ���� ���������� ����� ���������� ����� */
	imask = 0x4;	      /* ������������ ���� ���������� ����� ���������� ����� */
	AX0 = 0;
	MR2 = 0;
	I4 = CAM1;
	L4 = CAM1 + camsize;
	I5 = CAM2;
	L5 = CAM2 + camsize;
	I6 = CAM3;
	L6 = CAM3 + camsize;
	I7 = CAM4;
	L7 = CAM4 + camsize;
	I0 = 0x3FE1;
	L0 = 4;
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
	SET FL0;
	//int emulation
	ifc = 0x400;//frame
	idle;
	ifc = 0x1000;//row
	idle;
	cntr = 550;
	do s1 until ce;
s1:	nop;
	ifc = 0x400;
	cntr = 30;
	do s2 until ce;
s2:	nop;
	ifc = 0x200;
	cntr = 20;
	do s3 until ce;
s3:	nop;
	ifc = 0x400;
	cntr = 50;
	do s4 until ce;
s4:	nop;
	ifc = 0x200;
loop1:	IDLE; //�������� ���������� �� BDMA
	IF FLAG_IN JUMP loop1;
//	  IMASK = 0x180;
	imask = 0x14;
	SET FL0;
	AX0 = 0xF0;		//���������� ������������
	DM(0x3FE5) = AX0;
	RESET FL1;		//������ ������� INTR � FL1
	SET FL1;
	AX0 = DM(I2,M0);
	CALL word_output;
	AX0 = DM(I3,M0);
	AY0 = 327;
	AR = AX0 - AY0;
	IF GE JUMP row_output;
	AY0 = 15;
	AR = AX0 - AY0;
row_output:
	AX0 = AR;
	CALL word_output;
	L1 = 0;
	MX0 = I4;
	MX1 = I5;
	MY0 = I6;
	MY1 = I7;
	//����� ������ ������ ��� ���������� �����������
	AR = MR2 + 1;
	IF EQ JUMP second_bank;
	AY0 = CAM1 + camsize * ncams;
	AR = PASS -1;
	I4 = CAM1;
	I5 = CAM2;
	I6 = CAM3;
	I7 = CAM4;
	JUMP processing;
second_bank:
	AY0 = CAM1;
	I4 = CAM1 + camsize * ncams;
	I5 = CAM2 + camsize * ncams;
	I6 = CAM3 + camsize * ncams;
	I7 = CAM4 + camsize * ncams;
processing:
	MR2 = AR;

	AX0 = MX0;
	CALL cam_output;
	AX0 = camsize;
	AR = AX0 + AY0, AY0 = AR;
	AX0 = MX1;
	CALL cam_output;
	AX0 = camsize;
	AR = AX0 + AY0, AY0 = AR;
	AX0 = MY0;
	CALL cam_output;
	AX0 = camsize;
	AR = AX0 + AY0, AY0 = AR;
	AX0 = MY1;
	CALL cam_output;
	JUMP loop1;

cam_output:
	AR = AX0 - AY0, AX0 = AR;
	CALL word_output;
	AR = PASS AX0;
	IF EQ RTS;
	I1 = AY0;
	CNTR = AR;
	AX0 = DM(I1,M1);
	DO cam_output_loop UNTIL CE;
	CALL word_output;
cam_output_loop: AX0 = DM(I1,M1);
	RTS;

word_output:
	//������� �������� AX0 � ���� �/�
	//AX0: �������� ��� ������
	//AF,SR0,SR1,AX1: ��������
	AX1 = DM(0x3FE5);
	AF = TSTBIT 4 OF AX1;
	IF NE JUMP word_output;
	IO(0) = AX0;
	RESET FLAG_OUT;
	SET FLAG_OUT;
word_output1:
	AX1 = DM(0x3FE5);
	AF = TSTBIT 4 OF AX1;
	IF EQ JUMP word_output1;
	SR = ASHIFT MR0 BY -8 (LO);
wait_dsrtb0:
	AX1 = DM(0x3FE5);
	AF = TSTBIT 4 OF AX1;
	IF NE JUMP wait_dsrtb0;
	IO(0) = SR0;
	RESET FLAG_OUT;
	SET FLAG_OUT;
wait_dsrtb1:
	AX1 = DM(0x3FE5);
	AF = TSTBIT 4 OF AX1;
	IF EQ JUMP wait_dsrtb1;
	RTS;



frame:
	DIS INTS;
	POP STS;		/* ��������� �������� �������� IMASK �� ����� */
//	  IMASK = 0x89; 	  /* ��������������� ���������� ������ ������, BDMA � ������� */
	imask = 0x19;	       /* ��������������� ���������� ������ ������, BDMA � ������� */
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	IMASK = 0;
	ENA INTS;
	RTI;


row:	AF = AR - AY0;
	IF LT RTI;
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
	RTI;


receive:
	DIS INTS;
	POP STS;		/* ��������� �������� �������� IMASK �� ����� */
//	  IMASK = 0x216;	  /* ��������������� ���������� IRQ0,1,2,E � ���������� ����� */
	imask = 2;	    /* ��������������� ���������� IRQ0,1,2,E � ���������� ����� */
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	IMASK = 0;
	IFC = 0;
	ENA INTS;
	RTI;

eop: