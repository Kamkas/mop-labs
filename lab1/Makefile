NAME = lab1
BASE_DIR = $(PROJ_DIR)
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
