# Jank

CC ?= gcc

SRCDIR ?= src
OBJDIR ?= obj

SRCDIR := $(abspath $(SRCDIR))
OBJDIR := $(abspath $(OBJDIR))
SRCDIR := $(patsubst %/,%,$(SRCDIR))
OBJDIR := $(patsubst %/,%,$(OBJDIR))
SRCDIR := $(patsubst %\,%,$(SRCDIR))
OBJDIR := $(patsubst %\,%,$(OBJDIR))

CURDIR := $(abspath .)
CURDIR := $(patsubst %/,%,$(CURDIR))
CURDIR := $(patsubst %\,%,$(CURDIR))

DIRS := $(sort $(dir $(wildcard $(SRCDIR)/*/)))
DIRS := $(patsubst %/,%,$(DIRS))
DIRS := $(patsubst %\,%,$(DIRS))
BASEDIRS := $(notdir $(DIRS))

INCLUDEDIRS = $(addprefix -I$(SRCDIR)/,$(BASEDIRS))

ifdef OS
BINEXT := .exe
else
BINEXT := .bin
endif

BINNAME := cavecube

BIN := $(BINNAME)$(BINEXT)

CFLAGS += -Wall -Wextra -I. -g 

BINFLAGS += -lpthread -lm -lglfw

MKENV = NAME=$@ HEADDIR=$(CURDIR) SRCDIR=$(SRCDIR) OBJDIR=$(OBJDIR) COMMONMK=$(CURDIR)/common.mk CC="$(CC)" CFLAGS="$(CFLAGS) $(INCLUDEDIRS)"
MKENV2 = CC="$(CC)" CFLAGS="$(CFLAGS)"

ifndef OS
define null
	@echo > /dev/null
endef
else
define null
	@echo > NUL
endef
endif

all: bin

clean.flags:
	@$(eval FLAGS := clean)

clean: clean.flags files
	@echo Removing $(OBJDIR) $(BIN)...
ifndef OS
	@rm -rf $(OBJDIR) $(BIN)
else
	@if exist $(BIN) del /Q $(BIN)
	@if exist $(OBJDIR) rmdir /S /Q $(OBJDIR)
endif
	@echo Removed $(OBJDIR) $(BIN)

files: $(BASEDIRS)

$(BASEDIRS): FORCE
	@$(MAKE) --no-print-directory -C $(SRCDIR)/$@ -f Makefile.inc ${MKENV} $(FLAGS)

bin: FORCE $(BIN)

ifdef MKSUB
$(BIN): $(wildcard $(OBJDIR)/*/*.o)
	@echo Compiling $(BIN)...
	@$(CC) $(BINFLAGS) $(wildcard $(OBJDIR)/*/*.o) -o $(BIN)
	@echo Compiled $(BIN)
else
$(BIN): files
	@$(MAKE) --silent --no-print-directory -f $(lastword $(MAKEFILE_LIST)) ${MKENV2} MKSUB=y $@
endif

test:
	@echo $(SRCDIR)
	@echo $(OBJDIR)
	@echo $(BASEDIRS)
	@echo $(DIRS)

FORCE:

.PHONY: all clean clean.flags files bin bmsg test $(MKFILES)

