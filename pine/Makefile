# This Makefile kinda cursed but...oh well.
NIX_FLAGS=--extra-experimental-features 'nix-command flakes flake-self-attrs'

shell:
	nix-shell -E 'with import <nixpkgs> { }; callPackage ./package.nix { }'

build:
	mkdir build
	cd build
	cmake ..
	make
	cd ..

run: build
	./build/pine
