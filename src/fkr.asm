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
	ICNTL = 0x17;		/* настройка срабатывания прерываний по перепаду */
	IMASK = 8;		/* маскирование всех прерываний кроме прерывания BDMA */
	DIS TIMER;		/* запрет тиков таймера */
	JUMP start1;
	AX0 = DM(I6,M4), AR = AX0 + AY1; /* 0x0004: вектор обработки прерывания кадра (IRQ2) */
	DM(I6,M4) = AR;
	DM(I7,M4) = 0;
	JUMP frame;
start1: I0 = 0x3FE1;		/* 0x0008: IRQL1*/
	M1 = 1; 		/* установка инкрементора M5 в 1 */
	L0 = 0;
	DM(I0,M1) = 0x20;	/* установка адреса BIAD в 0x20 */
	DM(I0,M1) = 0x20;	/* 0x000C: IRQL0, установка адреса BEAD в 0x20 */
	DM(I0,M1) = 0;		/* установка направления - запись в ПП из БП с продолжением выполнения программы */
	DM(I0,M1) = eop - 0x20; /* запуск копирования из БП в ПП */
	IDLE;			/* 0x0010: SPORT0 передача, ожидание прерывания окончания закрузки программы из БП */
	DIS INTS;
	JUMP start;
	nop;
	RTI; nop; nop; nop;	/* 0x0014: SPORT0 приём */
	DM(I6,M4) = 8;		/* 0x0018: IRQE, загрузка в регистр счетчика BWCOUNT количества требуемых слов и запуск загрузки */
	CNTR = 128;
	DO waitloop UNTIL CE;
waitloop: NOP;
	RTI; nop; nop; nop;	/* 0x001C: BDMA*/
	ENA TIMER;		/* 0x0020: вектор обработки прерывания начала строки (INT1), разрешение тиков таймера */
	AX0 = DM(I7,M4), AR = AX0 + AY1; /* 0x0020: вектор обработки прерывания начала строки (INT1), разрешение тиков таймера */
	AY0 = 15;
	DM(I7,M4) = AR, AF = AR - AY0;
	JUMP row;
	RTI;			/* 0x0024: вектор обработки прерывания (INT0) */
	nop; nop; nop;
	DIS TIMER;		/* 0x0028: вектор обработки прерываний от таймера, запрет тиков таймера */
	DM(I0,M1) = 3;		/* установка режима чтения из ПД в режиме МЗБ */
	DM(I0,M0) = nx; 	/* загрузка в регистр счетчика BWCOUNT количества требуемых слов и запуск загрузки */
	JUMP timer_p;
	RTI; nop; nop; nop;	/* 0x002C: Power down*/


.section/pm program;
start:	M0 = 0; 		/* установка инкрементора M4 в 0 */
	DM(I0,M1) = 0x70;	/* установка данных в регисте программируемых флагов PF6-4 в 1 */
	DM(I0,M1) = 0x2B00;	/* настройка режима програмируемых флагов на ввод и установка 2-х циклов ожидания при чтении (+1 цикл на запись в ОЗУ из рассчета по формуле tBDMA) из регистра данных от камеры */
	DM(I0,M0) = 0;		/* установка нулевых блоков памяти по умолчанию */
	I0 = 0x3FFB;		/* TSCALE = 0x3FFB, TCOUNT = 0x3FFC, TPERIOD = 0x3FFD */
	DM(I0,M1) = 0;		/* настройка умножителя таймера TSCALE в 1 */
	DM(I0,M1) = pause;
	DM(I0,M1) = pause;	/* настройка счетчика таймера TPERIOD на пропуск сигналов от камер в течение 180 нс. */
	DM(I0,M1) = 0x7FFF;	/* настройка циклов ожидания IO */
	DM(I0,M0) = 7;		/* настройка порта SPORT1 на прием прерываний IRQ0, IRQ1 */
	I0 = 0x3FF3;		/* регистр управления автозаписью SPORT0 */
	DM(I0,M0) = 0;		/* отключение вывода CLKOUT */
	I0 = 0x3FEF;		/* регистр управления автозаписью SPORT1 */
	DM(I0,M0) = 0;		/* отключение особенностей Powerdown */
	M4 = 0; 		/* установка инкрементора M0 в 0 */
	M5 = 1; 		/* установка инкрементора M1 в 1 */
	IMASK = 0x200;		/* маскирование всех прерываний кроме прерывания кадра */
	I4 = BUFFER;		/* устновка счетчика адреса I4 в начало буфера данных значений сигналов */
	I5 = 0x1000;
	I6 = FRAME;		/* установка счетчика адреса I6 в начало буфера данных кадра */
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
	DM(I6,M4) = 0;		/* сброс счетчика кадров */
	SE = 2; 		/* установка направления и количества сдвигов - влево на 2 разряда */
	RESET FLAG_OUT;
	ENA INTS;		/* разрешение прерываний */
//	  AX0 = 1;
//	  CNTR = 8; // nx * ny / ((nx * k / 8) * 8)
loop1:	IDLE; //ожидание прерывания от таймера
	IF NOT FLAG_IN JUMP loop1;
start_performing:
	IMASK = 0x10;
	SE = -1;		 /* установка направления и количества сдвигов - вправо на 1 разряд */
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
	// вывод через BDMA
	DM(I0,M5) = FRAME;	/* установка адреса BIAD в адрес FRAME */
	DM(I0,M5) = 0;		/* установка адреса BEAD в 0 */
	DM(I0,M5) = 5;		/* установка режима записи в ПД в двухбайтовом режиме */
	// вывод через IO
	RESET FL0;
//	  SET FL0;
//	  CNTR = 16;
//	  DO loopout UNTIL CE;
//loopout: IDLE;
//loopny:  NOP;
loopny: SET FL0;	     /* установка счетчика адреса I6 в начало буфера данных кадра */
	I6 = FRAME;
	SE = 2; 		/* установка направления и количества сдвигов - влево на 2 разряда */
	RESET FLAG_OUT;
	JUMP loop1;


frame:	DM(I1,M0) = 0;
	POP STS;
	IMASK = 0x205;		/* получение значение регистра IMASK из стека и размаскирование прерывания начала строки и таймера */
//	  IMASK = 0x207;	  /* получение значение регистра IMASK из стека и размаскирование прерывания начала строки */
	PUSH STS;		/* сохранение нового значения регистра IMASK в стек */
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
	DM(I0,M1) = BUFFER;	/* установка адрес смещения BUFFER как адрес входного регистра BIAD в  */
	DM(I0,M1) = 0x2000;	/* установка адреса входного регистра BEAD в 0x2000 */
	RTI;



eop: