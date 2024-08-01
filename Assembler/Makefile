# Define Colors
PRINT_GENERATING=”Generating $(shell basename $@) ... ”
PRINT_BUILDING=”Building $(shell basename $@) ... ”

# Executable Name
EXE_NAME=asm

# Define the Compilers
CC=gcc
FLEX=flex
BISON=bison

# Define the Flags
CC_FLAGS=-Wall -g
BISON_FLAGS= -y -d

# Define the Objects Directory
OBJ_DIR=build

# Define the Output Directory
OUT_DIR=bin

# Define the Source Directory
SRC_DIR=src

# Define the Include Directory
INC_DIR=include

# Define the Include Files
INC_FILES=-I$(INC_DIR)

# Define the Source Files excluding main.c
SRC_FILES=$(wildcard $(SRC_DIR)/*.c)
SRC_FILES:=$(filter-out $(SRC_DIR)/main.c,$(SRC_FILES))

# Define the Object Files
OBJ_FILES=$(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))
OBJ_FILES+=$(OBJ_DIR)/$(PARSER_OBJECT)
OBJ_FILES+=$(OBJ_DIR)/$(LEXER_OBJECT)

# Define the BISON Files
PARSER_FILE=parser.y
PARSER_OUT=y.tab.c
PARSER_OBJECT=y.tab.o

# Define the LEXER Files
LEXER_FILE=scanner.l
LEXER_OUT=lex.yy.c
LEXER_OBJECT=lex.yy.o

# All
.DEFAULT_GOAL := all

all: $(OUT_DIR)/$(EXE_NAME)

# Setup
$(OBJ_DIR)/%.c: 
	@ mkdir -p $(OBJ_DIR)
	@ mkdir -p $(OUT_DIR)
	cp $(SRC_DIR)/* $(OBJ_DIR)
	cp $(INC_DIR)/* $(OBJ_DIR)
	@ echo "Generating Parser ..."
	cd $(OBJ_DIR) && $(BISON) $(BISON_FLAGS) $(PARSER_FILE)
	@ echo "Generating Lexer ..."
	cd $(OBJ_DIR) && $(FLEX) $(LEXER_FILE)
	@ echo "Building y.tab.c & lex.yy.c ..."
	cd $(OBJ_DIR) && $(CC) $(INC_FILES) $(CC_FLAGS) -c $(PARSER_OUT) $(LEXER_OUT)

# Compile Objects 
$(OBJ_DIR)/%.o: $(OBJ_DIR)/%.c
	@ echo $(PRINT_BUILDING)
	$(CC) $(INC_FILES) $(CC_FLAGS) -c $< -o $@

# Link Objects
$(OUT_DIR)/$(EXE_NAME): $(OBJ_FILES) 
	@ echo $(PRINT_GENERATING)
	$(CC) $(INC_FILES) $(CC_FLAGS) $(OBJ_FILES) $(OBJ_DIR)/main.c -o $(OUT_DIR)/$(EXE_NAME)

.PRECIOUS: $(OBJ_DIR)/%.c

# Run
run: 
	@ echo "Running ..."
	@ ./$(OUT_DIR)/$(EXE_NAME)


.PHONY: clean

# Clean
clean:
	@ echo "Cleaning ..."
	@ rm -rf $(OBJ_DIR)
	@ rm -rf $(OUT_DIR)