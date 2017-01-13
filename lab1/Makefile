NAME = lab1
BASE_DIR = /home/kamkas/Yandex.Disk/google-drive-mirror/ws/mop/mop-labs/
PROJ_DIR = BASE_DIR + $(NAME)/
LIBS_DIR = BASE_DIR + libs/
TEMP_DIR = PROJ_DIR + debug/
INC = $(LIBS_DIR) + stdlib.inc
CC = nasm
LD = ld

$(NAME).o : $(NAME).asm
	$(CC) -f elf $(NAME).asm -p $(INC)


build : $(NAME).o
	$(LD) -m elf_i386 $(NAME).o -o $(NAME)


run :
	./$(NAME)


clean :
	\rm *.o *~


all:
	build
	clean
	run