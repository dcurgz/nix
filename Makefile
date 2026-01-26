# Makefile to apply the Nix flake configuration to the system

REMOTE_BUILDER := ssh://builder

HOME_MANAGER := home-manager --extra-experimental-features "nix-command flakes"

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
	sudo nixos-rebuild --builders "$(REMOTE_BUILDER) x86_64-linux,aarch64-linux" --max-jobs 0 switch --flake .#piberry --show-trace

airberry:
	sudo darwin-rebuild switch --flake .#airberry 

miniberry:
	sudo darwin-rebuild switch --flake .#miniberry --show-trace

# Build home-manager configurations
C-DC-L14:
	$(HOME_MANAGER) --builders "$(REMOTE_BUILDER) x86_64-linux" switch --flake .#C-DC-L14 -b bak

bootstrap-weirdfi.sh:
	nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/weirdfi.sh-cax11-4gb/hardware-configuration.nix --flake .#weirdfish-cax11-4gb --target-host "root@weirdfi.sh"

# e.g. deploy .#hyperberry
deploy:
	deploy $(HOST) --skip-checks --skip-failures --fast-connection false -- --builders 'ssh://builder@hyperberry x86_64-linux,aarch64-linux 16 1' --builders-use-substitutes --max-jobs 0

weirdfi.sh:
	HOST=.#weirdfish-cax11-4gb make deploy 

# Update flake inputs and lock file
update:
	nix --extra-experimental-features flakes --extra-experimental-features nix-command flake update
