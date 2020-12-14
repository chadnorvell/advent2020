IDIR=.
ODIR=obj

CC=clang
CFLAGS=-I$(IDIR)

_DEPS=grid_infx.h
OBJ=$(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ=main.o grid_infx.o
OBJ=$(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

advent: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o advent core
