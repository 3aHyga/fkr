/****************************FKR on ADSP 2185********************************/
//программа рассчитанная на приём одного кадра, останов приёма происходит по приёму 313 строк, вывод в LPT отсутствует
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
	I0 = 0x3FE1;		/* установка адресов BDMA */
	M1 = 1; 		/* установка инкрементора M1 в 1 */
	L0 = 0; 		/* установка линейности буффера 0 */
	DM(I0,M1) = 0;		/* установка адреса BIAD в 0x0 */
	DM(I0,M1) = 0x60;	/* установка адреса BEAD в 0x60 */
	DM(I0,M1) = 8;		/* установка направления - запись в ПП из БП с продолжением выполнения программы */
	DM(I0,M1) = (eop - __reset) * 3; /* запуск копирования из БП в ПП */
	IDLE;

.section/pm interrupts; 				/*------Interrupt vector table------*/
    __reset: JUMP start; nop; nop; nop; 	/* 0x0000: Reset vector*/
irq2:
	JUMP frame;
	nop; nop; nop;
irql1:
	AX0 = DM(I0,M0);	/* чтение значения счетчика пикселей 1й камеры из регистра BDMA */
	DM(PROFILES+3) = AX0;	/* сохранение полученного значения в память */
	RTI; nop;
irql0:
	AX0 = DM(I0,M0);	/* чтение значения счетчика пикселей 1й камеры из регистра BDMA */
	DM(PROFILES+2) = AX0;	/* сохранение полученного значения в память */
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
	AX0 = DM(I0,M0);	/* чтение значения счетчика пикселей 1й камеры из регистра BDMA */
	DM(PROFILES+1) = AX0;	/* сохранение полученного значения в память */
	RTI; nop;
int0:
	AX0 = DM(I0,M0);	/* чтение значения счетчика пикселей 1й камеры из регистра BDMA */
	DM(PROFILES) = AX0;   /* сохранение полученного значения в память */
	RTI; nop;
__timer:
	JUMP pixel;
	nop; nop; nop;
powerdown:
	RTI; nop; nop; nop;



.section/pm program;
start:
	ICNTL = 0x17;		/* настройка срабатывания прерываний по перепаду */
	DIS TIMER;		/* запрет тиков таймера */
	DIS INTS;		/* запрет прерываний */
	M0 = 0; 		/* установка инкрементора M0 в 0 */
	IFC = 0xFF;
	DM(I0,M1) = 0xFF;	/* установка данных в регисте программируемых флагов PF7-0 в 1 */
	DM(I0,M1) = 0x7000;	/* настройка режима програмируемого флага 3 на вывод и установка 7-и циклов ожидания при чтении (+1 цикл на запись в ОЗУ из рассчета по формуле tBDMA) из регистра данных от камеры и установка нулевых блоков памяти по умолчанию */
	I0 = 0x3FFB;		/* TSCALE = 0x3FFB, TCOUNT = 0x3FFC, TPERIOD = 0x3FFD */
	DM(I0,M1) = 3;		/* настройка умножителя таймера TSCALE в 1 */
	DM(I0,M1) = pause;	/* настройка счетчика таймера TCOUNT на пропуск сигналов от камер в течение 180 мкс */
	DM(I0,M1) = pause;	/* настройка счетчика таймера TPERIOD на пропуск сигналов от камер в течение 180 мкс */
	DM(I0,M1) = 0;		/* настройка циклов ожидания IO */
	DM(I0,M0) = 7;		/* настройка порта SPORT1 на прием прерываний IRQ0, IRQ1 */
	I0 = 0x3FF3;		/* регистр управления автозаписью SPORT0 */
	DM(I0,M0) = 0;		/* отключение вывода CLKOUT */
	I0 = 0x3FEF;		/* регистр управления автозаписью SPORT1 */
	DM(I0,M0) = 0;		/* отключение особенностей Powerdown */
	M4 = 0; 		/* установка инкрементора M4 в 0 */
	M5 = 1; 		/* установка инкрементора M5 в 1 */
	IMASK = IFRAME; 	/* маскирование всех прерываний кроме прерывания кадра */
	AX0 = 0;		/* обнуление регистра AX0 */
	I0 = 0x3FFC;		/* установка адреса регистра счетчика таймера */
	L0 = 0; 		/* установка нулевой длины буфера регистра счетчика таймера */
	I1 = PROFILES;		/* установка кольцевого буфера на область памяти со значениями профиля */
	L1 = 0; 		/* установка нулевой длины буфера профилей */
	I2 = FRAME;		/* установка адреса счетчика кадров */
	L2 = 0; 		/* буфер для счетчика кадров не используется */
	I3 = ROW;		/* установка адреса счетчика строк в кадре */
	L3 = 0; 		/* буфер для счетчика строк не используется */
	I4 = CAMDATA;
	L4 = 0;
	I5 = CAMDATA;
	L5 = 0;
	AY1 = 1;		/* загрузка регистра AY1 значением для инкрементации */
	DM(I2,M0) = 0;		/* сброс счетчика кадров */
	ENA INTS;		/* разрешение прерываний */
	SET FL0;		/* сброс сигнала ОПД */
	ax1 = 0;
	dm(PAUSESW) = ax1;
	ax0 = frame_pause;
	dm(FRAMESW) = ax0;
	MR1 = 0;
loopm:	ENA INTS;		/* разрешение прерываний */
	IDLE;
	DIS INTS;
	AF = PASS MR1;
	IF EQ JUMP loopm;	/* проверка сигнала окончания према данных (ОПД) и если сигнал = 0, то начать вывод результата в паралельный порт */
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
	AX0 = DM(I2,M0);	/* загрузка значения текущего кадра в регистр AX0 */
	AR = AX0 + AY1; 	/* инкрементация значения текущего кадра */
	DM(I2,M0) = AR; 	/* сохранение полученного значения в память */
	DM(I3,M0) = 0;		/* обнуление значения текущей строки */
	I4 = CAMDATA;
	AX0 = DM(I2,M0);	/* загрузка значения текущего кадра в регистр MR0 */
	DM(I4,M5) = AX0;
	AX0 = last_row;        /* чтение текущей строки приемника */
	AR = AX0 - first_row;	/* вычитание из значения текущей строки значение строки, с которой начинается нечетный полукадр */
	DM(I4,M5) = AR;
	DIS INTS;		/* запрет прерываний */
	POP STS;		/* получение значение регистра IMASK из стека */
	IMASK = IFRAME | ITIMER | IROW;  /* размаскирование прерывания начала строки и таймера */
	PUSH STS;		/* сохранение нового значения регистра IMASK в стек */
	IMASK = 0;		/* блокирование прерываний */
	ENA INTS;		/* разрешение прерываний */
	RTI;
frame_next:
	dm(FRAMESW) = ar;
	rti;




row:
//	  reset fl0;
//	  set fl0;
	AX0 = DM(I3,M0);	/* загрузка значения текущей строки в регистр AX0 */
	AR = AX0 + AY1; 	/* инкрементация значения текущей строки */
	AY0 = first_row;	/* подготовка определения 15й строки */
	DM(I3,M0) = AR, AF = AR - AY0;	/* запись полученного результата в память и получение флагового значения результата вычитания нового значения строки и AY0 */
	IF LT RTI;		/* если значение строки < 15, то выход из обработчика */
	POP STS;		/* получение значений регистров состояния из стека */
	AY0 = last_row; 	/* подготовка определения 313й строки */
	AF = AR - AY0;		/* получение флагового значения результата вычитания нового значения строки и AY0 */
	IF GE JUMP row_fo;	/* если значение строки < 313, то переход на программу запуска таймера */
	ENA TIMER;		/* запуск таймера */
	AX0 = 0;
	DM(PROFILES) = AX0;	/* сохранение нулевого значения в память */
	DM(PROFILES+1) = AX0;	  /* сохранение нулевого значения в память */
	DM(PROFILES+2) = AX0;	  /* сохранение нулевого значения в память */
	DM(PROFILES+3) = AX0;	  /* сохранение нулевого значения в память */
	PUSH STS;		/* сохранение нового значения регистров состояния в стек */
	RTI;
row_fo:
	MR1 = 1;
	IMASK = IFRAME;
	PUSH STS;		/* сохранение нового значения регистра IMASK в стек */
	RTI;



pixel:
	dis ints;		/* запрет прерываний */
	pop sts;		/* получение значение регистра IMASK из стека */
//	  reset fl0, reset fl1, reset fl2;
//	  set fl0, set fl1, set fl2;
	AX1 = DM(PAUSESW);
	AR = NOT AX1;
	DM(PAUSESW) = AR;
	IF NE JUMP pixel1;
	IMASK = IROW | IFRAME | ITIMER;
	DM(I0,M0) = pause;
	dis timer;
	CNTR = 1;		/* загрузка в регистр счетчика количества действующих камер */
	I1 = PROFILES;			       /* установка кольцевого буфера на область памяти со значениями профиля */
	DO profiles_output UNTIL CE; /* организация цикла вывода профиля полученного с действующих камер */
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
	ifc = 0xff;		   /* сброс прерываний ожидающих обработки */
	push sts;		/* сохранение нового значения регистра IMASK в стек */
	imask = 0;	     /* блокирование прерываний */
	ena ints;		/* разрешение прерываний */
	rti;



word_output:
	//функция выводит значение MR0 в порт в/в
	//MR0: значение для вывода
	//AF,SR0,SR1,AX1: разрушены
//	  reset fl1, reset fl2;
//	  set fl1, set fl2;
	if flag_in jump wait_output5;
	cntr = 10;
	do word_outputl1 until ce;
word_outputl1: nop;
word_output1:
	AX1 = DM(0x3FE5);	/* загрузка в регистр AX1 значения сигналов программируемых портов */
	AF = TSTBIT 0 OF AX1;	/* проверка 0го бита являющегося сигналом DSTRB */
	IF NE JUMP word_output1; /* ожидание нулевого значения бита */
	IO(0) = MR0;		/* вывод в порт в/в младшего байта регистра MR0 */
	RESET FLAG_OUT; 	/* установка низкого (активного) уровня сигнала IWAIT (инверсный WAIT) */
word_output2:
	AX1 = DM(0x3FE5);	/* загрузка в регистр AX1 значения сигналов программируемых портов */
	AF = TSTBIT 0 OF AX1;	/* проверка 0го бита являющегося сигналом DSTRB */
	IF EQ JUMP word_output2; /* ожидание единичного значения бита */
	SET FLAG_OUT;		/* установка высокого (пассивного) уровня сигнала IWAIT (инверсный WAIT) */
	cntr = 30;
	do word_outputl2 until ce;
word_outputl2: nop;
	SR = ASHIFT MR0 BY -8 (LO); /* сдвиг значения регистра MR0 вправо на 8 бит и помещение результата в регистр SR */
wait_output3:
	AX1 = DM(0x3FE5);	/* загрузка в регистр AX1 значения сигналов программируемых портов */
	AF = TSTBIT 0 OF AX1;	/* проверка 0го бита являющегося сигналом DSTRB */
	IF NE JUMP wait_output3; /* ожидание нулевого значения бита */
	IO(0) = SR0;		/* вывод в порт в/в младшего байта регистра SR0 (старшего байта MR0) */
	RESET FLAG_OUT; 	/* установка низкого (активного) уровня сигнала IWAIT (инверсный WAIT) */
wait_output4:
	AX1 = DM(0x3FE5);	/* загрузка в регистр AX1 значения сигналов программируемых портов */
	AF = TSTBIT 0 OF AX1;	/* проверка 0го бита являющегося сигналом DSTRB */
	IF EQ JUMP wait_output4; /* ожидание единичного значения бита */
	SET FLAG_OUT;		/* установка высокого (пассивного) уровня сигнала IWAIT (инверсный WAIT) */
wait_output5:
	RTS;


eop: