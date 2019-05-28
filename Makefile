CC = gcc
CFLAGS = -w
TARGET = project3_21
OBJECTS = main.o util.o lex.o

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TARGET)

lex.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c -o lex.o

lex.yy.c: tiny.l globals.h util.h
	flex tiny.l

cminus.tab.o: cminus.tab.c cminus.tab.h
	$(CC) $(CFLAGS) -c cminus.tab.c

cminus.tab.c cminus.tab.h: yacc/cminus.y
	bison -d yacc/cminus.y

clean :
	rm *.o lex.yy.c project3_21
