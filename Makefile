CFLAGS := -O0 -g3 -ggdb -fno-omit-frame-pointer -fno-inline

default: build

# Configure with our CFLAGS in the environment so autoconf picks them up
configure:
	cd bash && CFLAGS="$(CFLAGS)" ./configure

build:
	# Let 'make' override CFLAGS if it must, but prefer ours via env
	cd bash && CFLAGS="$(CFLAGS)" $(MAKE) -j "$$(nproc)"

clean:
	# 'distclean' if present; fall back to 'clean'
	@if [ -f bash/Makefile ]; then \
	  $(MAKE) -C bash distclean || $(MAKE) -C bash clean; \
	fi

check:
	bash/bash -i bad.sh

good:
	gdb -q -x gdb.gdb bash/bash -ex "run -i ./good.sh" -ex "quit"

bad:
	gdb -q -x gdb.gdb bash/bash -ex "run -i ./bad.sh" -ex "quit"

simple:
	gdb -q -x gdb-simple.gdb bash/bash -ex "run -i ./bad.sh"

.PHONY: default configure build clean good bad simple

