default: build

configure:
	pushd bash && ./configure && popd

build:
	pushd bash && make -j $$(nproc) && popd

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
