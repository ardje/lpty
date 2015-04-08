# simple Makefile for lpty. Works for Linux, MacOS X, probably other unixen
#
# Gunnar Zötl <gz@tset.de>, 2010-2014
# Released under MIT/X11 license. See file LICENSE for details.

# try some automatic discovery
OS = $(shell uname -s)
LUAVERSION = $(shell lua -e "print(string.match(_VERSION, '%d+%.%d+'))")
LUA_BINDIR ?= $(shell dirname `which lua`)
LUAROOT = $(shell dirname $(LUA_BINDIR))

# Defaults
TARGET = lpty.so
#DEBUG = -g -lefence

CC ?= gcc
CFLAGS ?= -fPIC -Wall $(DEBUG)
LUA_INCDIR ?= $(LUAROOT)/include
LUA_LIBDIR ?= $(LUAROOT)/lib

# OS specialities
ifeq ($(OS),Darwin)
LIBFLAG ?= -bundle -undefined dynamic_lookup -all_load
else
LIBFLAG ?= -shared
endif

# install target locations
INST_DIR = /usr/local
INST_LIBDIR ?= $(INST_DIR)/lib/lua/$(LUAVERSION)
INST_LUADIR ?= $(INST_DIR)/share/lua/$(LUAVERSION)

all: $(TARGET)

$(TARGET): lpty.o
	$(CC) $(LIBFLAG) $(DEBUG) -o $@ -L$(LUA_LIBDIR) $<

lpty.o: lpty.c expectsrc.inc
	$(CC) $(CFLAGS) -I$(LUA_INCDIR) -c $< -o $@

%.inc: %.lua
	lua mkinc.lua `basename $@ .inc`

install: all
	mkdir -p $(INST_LIBDIR)
	cp $(TARGET) $(INST_LIBDIR)

test: all
	cd samples && LUA_CPATH=../\?.so lua lptytest.lua

clean:
	find . -name "*~" -exec rm {} \;
	find . -name .DS_Store -exec rm {} \;
	find . -name "._*" -exec rm {} \;
	rm -f *.o *.so core *.inc
