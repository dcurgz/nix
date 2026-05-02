# Makefile to apply the Nix flake configuration to the system

REMOTE_BUILDER := --builders "ssh://builder@hyperberry x86_64-linux,aarch64-linux - 16 1 ; ssh://builder@miniberry aarch64-darwin - 16 1"

HOME_MANAGER := home-manager --extra-experimental-features "nix-command flakes"

NIX := nix --extra-experimental-features "nix-command flakes" --extra-deprecated-features url-literals
NOM := --log-format internal-json -v |& nom --json

HOSTNAME := $(shell cat /etc/hostname)

CHECK_MINECRAFT := ssh vm-mc-leedlemon "rcon-cli --password leedlemon list" || true

.PHONY: hyperberry piberry airberry update

update-index:
	git add -A

# weird Nix bug where local relative flake inputs are broken when they are
# garbage collected from the nix store
update-local-inputs:
	nix flake update neoforge-server
	nix flake update nix-time
	nix flake update weirdfish-server

# Build host-specific configurations
hyperberry: update-index
	# Fix permissions
	sudo chown -R root:wheel /etc/nixos
	sudo chmod -R 774 /etc/nixos
	# Go!
	$(CHECK_MINECRAFT)
	@read -p "Proceed? [y/N] " ans && ans=$${ans:-N} ; \
	if [ $${ans} = y ] || [ $${ans} = Y ]; then \
		sudo nixos-rebuild boot --flake .#hyperberry ; \
	fi

blueberry: update-index
	# Fix permissions
	sudo chown -R root:wheel /etc/nixos
	sudo chmod -R 774 /etc/nixos
	# Go!
	sudo nixos-rebuild --no-reexec switch --flake .#blueberry $(NOM)

piberry: update-index
	sudo nixos-rebuild $(REMOTE_BUILDER) --max-jobs 0 switch --flake .#piberry

piberry-sdcard: update-index
	sudo $(NIX) build .#nixosConfigurations.piberry.config.system.build.images.sd-card

tauberry: update-index
	sudo nixos-rebuild $(REMOTE_BUILDER) --max-jobs 0 switch --flake .#tauberry

tauberry-sdcard: update-index
	sudo $(NIX) build .#nixosConfigurations.tauberry.config.system.build.images.sd-card

airberry: update-index
	sudo darwin-rebuild switch --option builders "ssh://builder@miniberry aarch64-darwin - 16 1" --max-jobs 0 --flake .#airberry 

miniberry: update-index
	sudo darwin-rebuild switch --flake .#miniberry --show-trace

bootstrap-weirdfi.sh: update-index
	$(NIX) run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/weirdfi.sh-cax11-4gb/hardware-configuration.nix --flake .#weirdfish-cax11-4gb --target-host "root@weirdfi.sh"

bootstrap-publicproxy: update-index
	$(NIX) run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/publicproxy-cax11-4gb/hardware-configuration.nix --flake .#publicproxy-cax11-4gb --target-host "root@publicproxy"

deploy: update-index
ifeq ($(HOSTNAME),hyperberry)
	# build locally
	deploy $(HOST) --skip-checks --skip-offline --fast-connection true -- --builders 'ssh://builder@miniberry aarch64-darwin - 16 1' --builders-use-substitutes --max-jobs 16 
else
	# build remotely
	deploy $(HOST) --skip-checks --skip-offline --fast-connection false -- $(REMOTE_BUILDER) --builders-use-substitutes --max-jobs 0 
endif

weirdfi.sh:
	HOST=.#weirdfish-cax11-4gb make deploy 

publicproxy:
	HOST=.#publicproxy-cax11-4gb make deploy 

# Update flake inputs and lock file
update:
	$(NIX) flake update
