NIX_FLAGS=--extra-experimental-features 'nix-command flakes flake-self-attrs'

develop:
	nix develop $(NIX_FLAGS)

compile:
	mkdir build || true
	cmake -S . -B build
	cd build && make

run: compile
	./build/pine
