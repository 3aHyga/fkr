/****************************FKR on ADSP 2185********************************/
//��������� ������������ �� ���� ������ �����, ������� ����� ���������� �� ����� 313 �����, ����� � LPT �����������
#define nx 440
#define first_row 16
#define last_row 307
#define pause 34
#define camscount 4
#define camsize 1024
#define frame_pause 25

#define ITIMER 0x1
#define IRQ0   0x2
#define IRQ1   0x4
#define IRQ2   0x200
#define IRQE   0x10

#define IFRAME IRQ2
#define IROW   IRQE
#define IDATA1 IRQ0
#define IDATA2 IRQ1


.section/data	framedata;
.VAR	FRAME = 0;
.VAR	ROW = 0;
.VAR	PAUSESW = 0;
.VAR	FRAMESW = 0;
.VAR	PROFILES[camscount];
.VAR	CAMDATA[camscount*camsize];

.section/pm	boot1;
	DIS INTS;
	I0 = 0x3FE1;		/* ��������� ������� BDMA */
	M1 = 1; 		/* ��������� ������������ M1 � 1 */
	L0 = 0; 		/* ��������� ���������� ������� 0 */
	DM(I0,M1) = 0;		/* ��������� ������ BIAD � 0x0 */
	DM(I0,M1) = 0x60;	/* ��������� ������ BEAD � 0x60 */
	DM(I0,M1) = 8;		/* ��������� ����������� - ������ � �� �� �� � ������������ ���������� ��������� */
	DM(I0,M1) = (eop - __reset) * 3; /* ������ ����������� �� �� � �� */
	IDLE;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset: JUMP start; nop; nop; nop; 	/* 0x0000: Reset vector*/
irq2:
	JUMP frame;
	nop; nop; nop;
irql1:
	AX0 = DM(I0,M0);	/* ������ �������� �������� �������� 1� ������ �� �������� BDMA */
	DM(PROFILES+3) = AX0;	/* ���������� ����������� �������� � ������ */
	RTI; nop;
irql0:
	AX0 = DM(I0,M0);	/* ������ �������� �������� �������� 1� ������ �� �������� BDMA */
	DM(PROFILES+2) = AX0;	/* ���������� ����������� �������� � ������ */
	RTI; nop;
sport0t:
	RTI; nop; nop; nop;
sport0r:
	RTI; nop; nop; nop;
irqe:
	JUMP row;
	nop; nop; nop;
bdma:
	RTI; nop; nop; nop;
int1:
	AX0 = DM(I0,M0);	/* ������ �������� �������� �������� 1� ������ �� �������� BDMA */
	DM(PROFILES+1) = AX0;	/* ���������� ����������� �������� � ������ */
	RTI; nop;
int0:
	AX0 = DM(I0,M0);	/* ������ �������� �������� �������� 1� ������ �� �������� BDMA */
	DM(PROFILES) = AX0;   /* ���������� ����������� �������� � ������ */
	RTI; nop;
__timer:
	JUMP pixel;
	nop; nop; nop;
powerdown:
	RTI; nop; nop; nop;



.section/pm program;
start:
	ICNTL = 0x17;		/* ��������� ������������ ���������� �� �������� */
	DIS TIMER;		/* ������ ����� ������� */
	DIS INTS;		/* ������ ���������� */
	M0 = 0; 		/* ��������� ������������ M0 � 0 */
	IFC = 0xFF;
	DM(I0,M1) = 0xFF;	/* ��������� ������ � ������� ��������������� ������ PF7-0 � 1 */
	DM(I0,M1) = 0x7000;	/* ��������� ������ ��������������� ����� 3 �� ����� � ��������� 7-� ������ �������� ��� ������ (+1 ���� �� ������ � ��� �� �������� �� ������� tBDMA) �� �������� ������ �� ������ � ��������� ������� ������ ������ �� ��������� */
	I0 = 0x3FFB;		/* TSCALE = 0x3FFB, TCOUNT = 0x3FFC, TPERIOD = 0x3FFD */
	DM(I0,M1) = 3;		/* ��������� ���������� ������� TSCALE � 1 */
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
	IMASK = IFRAME; 	/* ������������ ���� ���������� ����� ���������� ����� */
	AX0 = 0;		/* ��������� �������� AX0 */
	I0 = 0x3FFC;		/* ��������� ������ �������� �������� ������� */
	L0 = 0; 		/* ��������� ������� ����� ������ �������� �������� ������� */
	I1 = PROFILES;		/* ��������� ���������� ������ �� ������� ������ �� ���������� ������� */
	L1 = 0; 		/* ��������� ������� ����� ������ �������� */
	I2 = FRAME;		/* ��������� ������ �������� ������ */
	L2 = 0; 		/* ����� ��� �������� ������ �� ������������ */
	I3 = ROW;		/* ��������� ������ �������� ����� � ����� */
	L3 = 0; 		/* ����� ��� �������� ����� �� ������������ */
	I4 = CAMDATA;
	L4 = 0;
	I5 = CAMDATA;
	L5 = 0;
	AY1 = 1;		/* �������� �������� AY1 ��������� ��� ������������� */
	DM(I2,M0) = 0;		/* ����� �������� ������ */
	ENA INTS;		/* ���������� ���������� */
	SET FL0;		/* ����� ������� ��� */
	ax1 = 0;
	dm(PAUSESW) = ax1;
	ax0 = frame_pause;
	dm(FRAMESW) = ax0;
	MR1 = 0;
loopm:	ENA INTS;		/* ���������� ���������� */
	IDLE;
	DIS INTS;
	AF = PASS MR1;
	IF EQ JUMP loopm;	/* �������� ������� ��������� ����� ������ (���) � ���� ������ = 0, �� ������ ����� ���������� � ����������� ���� */
	reset fl1, reset fl2;
	set fl1, set fl2;
	I5 = CAMDATA;
	AX0 = I4;
	AY0 = I5;
	AR = AX0 - AY0;
	MR0 = AR;
	MR1 = AR;
	ENA INTS;
	CALL word_output;
	CNTR = MR1;
	DO loop_output UNTIL CE;
	MR0 = DM(I5,M5);
	CALL word_output;
loop_output: nop;
	MR1 = 0;
	jump loopm;


	RESET FL0, RESET FL1;
	SET FL0, SET FL1;
	rti;
frame_rti:
	RESET FL2, RESET FLAG_OUT;
	SET FL2, SET FLAG_OUT;
	rti;


frame:
	ax0 = dm(FRAMESW);
	ar = ax0 - 1;
	if ne jump frame_next;
	ax0 = frame_pause;
	dm(FRAMESW) = ax0;
	AX0 = DM(I2,M0);	/* �������� �������� �������� ����� � ������� AX0 */
	AR = AX0 + AY1; 	/* ������������� �������� �������� ����� */
	DM(I2,M0) = AR; 	/* ���������� ����������� �������� � ������ */
	DM(I3,M0) = 0;		/* ��������� �������� ������� ������ */
	I4 = CAMDATA;
	AX0 = DM(I2,M0);	/* �������� �������� �������� ����� � ������� MR0 */
	DM(I4,M5) = AX0;
	AX0 = last_row;        /* ������ ������� ������ ��������� */
	AR = AX0 - first_row;	/* ��������� �� �������� ������� ������ �������� ������, � ������� ���������� �������� �������� */
	DM(I4,M5) = AR;
	DIS INTS;		/* ������ ���������� */
	POP STS;		/* ��������� �������� �������� IMASK �� ����� */
	IMASK = IFRAME | ITIMER | IROW;  /* ��������������� ���������� ������ ������ � ������� */
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	IMASK = 0;		/* ������������ ���������� */
	ENA INTS;		/* ���������� ���������� */
	RTI;
frame_next:
	dm(FRAMESW) = ar;
	rti;




row:
//	  reset fl0;
//	  set fl0;
	AX0 = DM(I3,M0);	/* �������� �������� ������� ������ � ������� AX0 */
	AR = AX0 + AY1; 	/* ������������� �������� ������� ������ */
	AY0 = first_row;	/* ���������� ����������� 15� ������ */
	DM(I3,M0) = AR, AF = AR - AY0;	/* ������ ����������� ���������� � ������ � ��������� ��������� �������� ���������� ��������� ������ �������� ������ � AY0 */
	IF LT RTI;		/* ���� �������� ������ < 15, �� ����� �� ����������� */
	POP STS;		/* ��������� �������� ��������� ��������� �� ����� */
	AY0 = last_row; 	/* ���������� ����������� 313� ������ */
	AF = AR - AY0;		/* ��������� ��������� �������� ���������� ��������� ������ �������� ������ � AY0 */
	IF GE JUMP row_fo;	/* ���� �������� ������ < 313, �� ������� �� ��������� ������� ������� */
	ENA TIMER;		/* ������ ������� */
	AX0 = 0;
	DM(PROFILES) = AX0;	/* ���������� �������� �������� � ������ */
	DM(PROFILES+1) = AX0;	  /* ���������� �������� �������� � ������ */
	DM(PROFILES+2) = AX0;	  /* ���������� �������� �������� � ������ */
	DM(PROFILES+3) = AX0;	  /* ���������� �������� �������� � ������ */
	PUSH STS;		/* ���������� ������ �������� ��������� ��������� � ���� */
	RTI;
row_fo:
	MR1 = 1;
	IMASK = IFRAME;
	PUSH STS;		/* ���������� ������ �������� �������� IMASK � ���� */
	RTI;



pixel:
	dis ints;		/* ������ ���������� */
	pop sts;		/* ��������� �������� �������� IMASK �� ����� */
//	  reset fl0, reset fl1, reset fl2;
//	  set fl0, set fl1, set fl2;
	AX1 = DM(PAUSESW);
	AR = NOT AX1;
	DM(PAUSESW) = AR;
	IF NE JUMP pixel1;
	IMASK = IROW | IFRAME | ITIMER;
	DM(I0,M0) = pause;
	dis timer;
	CNTR = 1;		/* �������� � ������� �������� ���������� ����������� ����� */
	I1 = PROFILES;			       /* ��������� ���������� ������ �� ������� ������ �� ���������� ������� */
	DO profiles_output UNTIL CE; /* ����������� ����� ������ ������� ����������� � ����������� ����� */
	AY0 = DM(I1,M1);
	AX0 = nx;
	AR = AX0 - AY0;
	DM(I4,M5) = AR;
profiles_output: nop;
	jump pixel_exit;
pixel1:
	IMASK = IROW | IFRAME | ITIMER | IDATA1;
	DM(I0,M0) = nx;
pixel_exit:
	ifc = 0xff;		   /* ����� ���������� ��������� ��������� */
	push sts;		/* ���������� ������ �������� �������� IMASK � ���� */
	imask = 0;	     /* ������������ ���������� */
	ena ints;		/* ���������� ���������� */
	rti;



word_output:
	//������� ������� �������� MR0 � ���� �/�
	//MR0: �������� ��� ������
	//AF,SR0,SR1,AX1: ���������
//	  reset fl1, reset fl2;
//	  set fl1, set fl2;
	if flag_in jump wait_output5;
	cntr = 10;
	do word_outputl1 until ce;
word_outputl1: nop;
word_output1:
	AX1 = DM(0x3FE5);	/* �������� � ������� AX1 �������� �������� ��������������� ������ */
	AF = TSTBIT 0 OF AX1;	/* �������� 0�� ���� ����������� �������� DSTRB */
	IF NE JUMP word_output1; /* �������� �������� �������� ���� */
	IO(0) = MR0;		/* ����� � ���� �/� �������� ����� �������� MR0 */
	RESET FLAG_OUT; 	/* ��������� ������� (���������) ������ ������� IWAIT (��������� WAIT) */
word_output2:
	AX1 = DM(0x3FE5);	/* �������� � ������� AX1 �������� �������� ��������������� ������ */
	AF = TSTBIT 0 OF AX1;	/* �������� 0�� ���� ����������� �������� DSTRB */
	IF EQ JUMP word_output2; /* �������� ���������� �������� ���� */
	SET FLAG_OUT;		/* ��������� �������� (����������) ������ ������� IWAIT (��������� WAIT) */
	cntr = 30;
	do word_outputl2 until ce;
word_outputl2: nop;
	SR = ASHIFT MR0 BY -8 (LO); /* ����� �������� �������� MR0 ������ �� 8 ��� � ��������� ���������� � ������� SR */
wait_output3:
	AX1 = DM(0x3FE5);	/* �������� � ������� AX1 �������� �������� ��������������� ������ */
	AF = TSTBIT 0 OF AX1;	/* �������� 0�� ���� ����������� �������� DSTRB */
	IF NE JUMP wait_output3; /* �������� �������� �������� ���� */
	IO(0) = SR0;		/* ����� � ���� �/� �������� ����� �������� SR0 (�������� ����� MR0) */
	RESET FLAG_OUT; 	/* ��������� ������� (���������) ������ ������� IWAIT (��������� WAIT) */
wait_output4:
	AX1 = DM(0x3FE5);	/* �������� � ������� AX1 �������� �������� ��������������� ������ */
	AF = TSTBIT 0 OF AX1;	/* �������� 0�� ���� ����������� �������� DSTRB */
	IF EQ JUMP wait_output4; /* �������� ���������� �������� ���� */
	SET FLAG_OUT;		/* ��������� �������� (����������) ������ ������� IWAIT (��������� WAIT) */
wait_output5:
	RTS;


eop: