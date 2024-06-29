C_SRC_DIR := $(shell pwd)/c_src
SRC := ${C_SRC_DIC}/decoder_nif.c ${C_SRC_DIC}/decoder.c

TARGET := priv/decoder.so
TARGET_DIR := $(dir $(TARGET))

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
	CC := cc
	LDFLAGS := -undefined dynamic_lookup -dynamiclib
else ifeq ($(UNAME), FreeBSD)
	CC := cc
else ifeq ($(UNAME), Linux)
	CC := gcc
	CFLAGS += -D_POSIX_C_SOURCE=199309L
endif

ERTS_INCLUDE_DIR=$(shell erl -noshell -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop)
CFLAGS += -std=c99 -finline-functions -Wall -fPIC -I $(ERTS_INCLUDE_DIR)
OBJ = $(addprefix $(C_SRC_DIR), $(addsuffix .o, $(basename $(SRC))))

ifdef DEBUG
	CFLAGS += -O0 -g3 -fno-omit-frame-pointer -DSQLITE_DEBUG
else
	CFLAGS += -O3
endif

LDFLAGS += -shared

.PHONY: clean all

$(TARGET): $(OBJ)
	mkdir -p $(TARGET_DIR)
	$(CC) $(OBJ) $(LDFLAGS) $(LDLIBS) -o $(TARGET)

$(C_SRC_DIR)/%.o: $(C_SRC_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

all: $(TARGET)

clean:
	@rm -f $(OBJ) $(TARGET)
