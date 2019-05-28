CC = gcc
CFLAGS = -w -std=gnu99
TARGET = project3_21
OBJECTS = main.o util.o lex.o cminus.o

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TARGET)

main.o: main.c globals.h util.h scan.h
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) -lfl

lex.o: lex.yy.c globals.h util.h scan.h
	$(CC) $(CFLAGS) -c lex.yy.c -o lex.o

lex.yy.c: tiny.l
	flex tiny.l

cminus.o: cm.tab.c cm.tab.h
	$(CC) $(CFLAGS) -c cm.tab.c

cm.tab.c cm.tab.h: cm.y
	bison -d cm.y

clean :
	rm *.o lex.yy.c project3_21
