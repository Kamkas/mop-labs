NAME = lab2
BASE_DIR = /media/kamkas/791a3122-bcaf-4bf8-b3f2-8256f4125e131/kamkas/Yandex.Disk/google-drive-mirror/ws/mop/mop-labs/
PROJ_DIR = $(BASE_DIR)$(NAME)/
LIBS_DIR = $(BASE_DIR)libs/
TEMP_DIR = $(PROJ_DIR)debug/
INC = $(LIBS_DIR)stdlib.inc
CC = nasm
LD = ld

$(NAME).o : $(NAME).asm
	$(CC) -f elf $(NAME).asm -p $(INC) -l $(NAME).lst


build : $(NAME).o
	$(LD) -m elf_i386 $(NAME).o -o $(NAME)


run :
	./$(NAME)


clean :
	\rm *.o $(NAME).lst $(NAME)
