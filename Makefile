.PHONY = default clear build dump run

default: build run

clear:
	rm -rf *.o *.dump main
build: main.asm
	fasm main.asm
	ld main.o -o main
dump: main
	objdump -S -M intel -d main > obj.dump
	cat obj.dump
run: main
	./main
