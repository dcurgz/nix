# Makefile to apply the Nix flake configuration to the system

REMOTE_BUILDER := --builders "ssh://builder@hyperberry x86_64-linux,aarch64-linux - 16 1 ; ssh://builder@miniberry aarch64-darwin - 16 1"

HOME_MANAGER := home-manager --extra-experimental-features "nix-command flakes"

NIX := nix --extra-experimental-features "nix-command flakes"

HOSTNAME := $(shell cat /etc/hostname)

.PHONY: hyperberry piberry airberry update

# Build host-specific configurations
hyperberry:
	# Fix permissions
	sudo chown -R root:wheel /etc/nixos
	sudo chmod -R 774 /etc/nixos
	# Go!
	sudo nixos-rebuild switch --flake .#hyperberry --fast

blueberry:
	# Fix permissions
	sudo chown -R root:wheel /etc/nixos
	sudo chmod -R 774 /etc/nixos
	# Go!
	sudo nixos-rebuild switch --flake .#blueberry 

piberry:
	sudo nixos-rebuild $(REMOTE_BUILDER) --max-jobs 0 switch --flake .#piberry

piberry-sdcard:
	sudo $(NIX) build .#nixosConfigurations.piberry.config.system.build.images.sd-card

tauberry:
	sudo nixos-rebuild $(REMOTE_BUILDER) --max-jobs 0 switch --flake .#tauberry

tauberry-sdcard:
	sudo $(NIX) build .#nixosConfigurations.tauberry.config.system.build.images.sd-card

airberry:
	sudo darwin-rebuild switch --option builders "ssh://builder@miniberry aarch64-darwin - 16 1" --max-jobs 0 --flake .#airberry 

miniberry:
	sudo darwin-rebuild switch --flake .#miniberry --show-trace

bootstrap-weirdfi.sh:
	$(NIX) run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/weirdfi.sh-cax11-4gb/hardware-configuration.$(NIX) --flake .#weirdfish-cax11-4gb --target-host "root@weirdfi.sh"

deploy:
#ifeq ($(HOSTNAME),hyperberry)
	# build locally
	deploy $(HOST) --skip-checks --skip-offline --fast-connection true --confirm-timeout 333 --activation-timeout 999 -- --builders 'ssh://builder@miniberry aarch64-darwin - 16 1' --builders-use-substitutes --max-jobs 16 
#else
	# build remotely
	#deploy $(HOST) --skip-checks --skip-offline --fast-connection false -- $(REMOTE_BUILDER) --builders-use-substitutes --max-jobs 0
#endif

weirdfi.sh:
	HOST=.#weirdfish-cax11-4gb make deploy 

# Update flake inputs and lock file
update:
	$(NIX) flake update
