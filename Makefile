CFLAGS := "-O0 -g3 -ggdb -fno-omit-frame-pointer -fno-inline"

default: build

configure:
	pushd bash && CFLAGS=$(CFLAGS) ./configure && popd

build:
	pushd bash && make -j $$(nproc) CFLAGS=$(CFLAGS) && popd

clean:
	pushd bash && make clean && popd

good:
	gdb -q -x histbug.gdb ./bash -ex "run -i ./good.sh" -ex "quit"

bad:
	gdb -q -x histbug.gdb ./bash -ex "run -i ./bad.sh" -ex "quit"

run:
	echo "Running good code"
	bash/bash -i good.sh
	echo "Running bad code"
	bash/bash -i bad.sh

.PHONY: default configure build good bad run
