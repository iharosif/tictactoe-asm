run:
	./build/program

build: assemble linkgcc

assemble:
	nasm -o ./build/main.out -f elf64 main.asm

linkgcc:
	gcc -nostartfiles -no-pie ./build/main.out -o ./build/program
