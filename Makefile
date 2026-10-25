run:
	./build/prog

build: assemble link

assemble:
	nasm -o ./build/main.out -f elf64 main.asm

link:
	ld -o ./build/prog ./build/main.out
