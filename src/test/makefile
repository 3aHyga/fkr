# this is a comment
PROC=adsp-2185
SRC=test.asm
OBJ=$(SRC:.asm=.do) # replaces the .asm from SRC with .obj
BIN=test.bin
EXE=$(BIN:.bin=.dxe)
LDF=$(PROC).ldf


AS=easm218x
CC=cc218x
LINK=linker
BINC=binc
PROG=c:\progra~1\picprogw\picprog.bat
AFLAGS=-li $(SRC:.asm=.lst) -o $@ -g $< -proc $(PROC)
CFLAGS=-L .  -proc $(PROC) -o $@ -g $<
LFLAGS=-Map $(EXE:.dxe=.map) -L. -S -s -o $@ -T $(LDF)
RM=rm

# combined w/ next line will compile recently changed .asm files
%.do: %.asm
	$(AS) $(AFLAGS)

%.do: %.c
	$(CC) $(CFLAGS)

$(BIN): $(EXE)
	$(BINC) $< $@

$(EXE): $(OBJ) $(LDF)  # $(EXE) is dependent on all of the files in $(OBJ) and $(LDF) to exist
	$(LINK) $(LFLAGS) $(OBJ)

.PHONY : all	 # .PHONY ignores files named all
all: $(BIN)	 # all is dependent on $(BIN) to be complete

.PHONY : clean	 # .PHONY ignores files named clean
clean:
	-$(RM) $(OBJ) core    # '-' causes errors not to exit the process

.PHONY : prog
prog:
	$(PROG) $(BIN)
