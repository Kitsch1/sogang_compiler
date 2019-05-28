CC = gcc
CFLAGS = -w -std=gnu99
TARGET = project3_21
OBJECTS = main.o util.o lex.o cm.tab.o

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TARGET) -lfl

util.o: util.c util.h globals.h 
	$(CC) $(CFLAGS) -c util.c

lex.o: lex.yy.c globals.h util.h scan.h
	$(CC) $(CFLAGS) -c lex.yy.c -o lex.o

lex.yy.c: tiny.l
	flex tiny.l

cm.tab.o: cm.tab.c cm.tab.h
	$(CC) $(CFLAGS) -c cm.tab.c

cm.tab.c cm.tab.h: cm.y
	bison -d cm.y

clean :
	rm *.o lex.yy.c project3_21 cm.tab.c cm.tab.h
