# this is a comment
PROC=adsp-2185
#SRC=multifi.asm
SRC=fkr.asm
OBJ=$(SRC:.asm=.do) # replaces the .asm from SRC with .obj
EXE=fkr.dxe
#EXE=multifi.dxe
LDF=$(PROC).ldf

AS=easm218x
CC=cc218x
LINK=linker
AFLAGS=
CFLAGS=-L .
LFLAGS=-Map $(EXE:.dxe=.map) -L.
RM=rm

# combined w/ next line will compile recently changed .asm files
%.do: %.asm
	$(AS) $(AFLAGS) -proc $(PROC) -o $@ -g $<

%.do: %.c
	$(CC) $(CFLAGS) -proc $(PROC) -o $@ -g $<

.PHONY : all	 # .PHONY ignores files named all
all: $(EXE)	 # all is dependent on $(EXE) to be complete

$(EXE): $(OBJ) $(LDF)  # $(EXE) is dependent on all of the files in $(OBJ) to exist
	$(LINK) $(LFLAGS) -T $(LDF) -o $@ $(OBJ)

.PHONY : clean	 # .PHONY ignores files named clean
clean:
	-$(RM) $(OBJ) core    # '-' causes errors not to exit the process

.PHONY : release     # .PHONY ignores files named all
