NIX_FLAGS=--extra-experimental-features 'nix-command flakes flake-self-attrs'

run: compile
	./build/pine

compile:
	mkdir build || true
	cmake -S . -B build
	cd build && make
