# Makefile to apply the Nix flake configuration to the system

BUILDER_OPTS := \
		--option builders-use-substitutes true \
		--option always-allow-substitutes true

BUILDERS_HB := \
		ssh://builder@miniberry aarch64-darwin - 16 4 ; \
		ssh://root@vm-mb-build-aarch64 aarch64-linux - 8 4 big-parallel,kvm

BUILDERS := \
		ssh://builder@hyperberry x86_64-linux - 16 2 ; \
		ssh://builder@miniberry aarch64-darwin - 16 4 ; \
		ssh://root@vm-mb-build-aarch64 aarch64-linux - 8 4 big-parallel,kvm

HOME_MANAGER := home-manager --extra-experimental-features "nix-command flakes"

NIX := nix --extra-experimental-features "nix-command flakes" --extra-deprecated-features url-literals
NOM := --log-format internal-json -v 2>&1 | nom --json

HOSTNAME := $(shell cat /etc/hostname)

CHECK_MINECRAFT := ssh vm-mc-leedlemon-0 -o "ConnectTimeout=3" "rcon-cli --password leedlemon list" || true

.PHONY: hyperberry piberry airberry update

update-index:
	git add -A

# weird Nix bug where local relative flake inputs are broken when they are
# garbage collected from the nix store
update-local-inputs:
	nix flake update mandoc-forked
	nix flake update neoforge-1-21-1
	nix flake update nix-time
	nix flake update weirdfish-server

# Build host-specific configurations
hyperberry: update-local-inputs update-index
	# Fix permissions
	sudo chown -R root:wheel /etc/nixos
	sudo chmod -R 774 /etc/nixos
	# Go!
	$(CHECK_MINECRAFT)
	@read -p "Proceed? [y/N] " ans && ans=$${ans:-N} ; \
	if [ $${ans} = y ] || [ $${ans} = Y ]; then \
		sudo nixos-rebuild switch --offline --flake .#hyperberry ; \
	fi

blueberry: update-local-inputs update-index
	# Fix permissions
	sudo chown -R root:wheel /etc/nixos
	sudo chmod -R 774 /etc/nixos
	# Go!
	sudo nixos-rebuild switch --flake .#blueberry \
		$(BUILDER_OPTS) \
		--builders '$(BUILDERS)' \
		$(NOM)

piberry: update-local-inputs update-index
	sudo nixos-rebuild --max-jobs 0 switch --flake .#piberry \
		$(BUILDER_OPTS) \
		--builders '$(BUILDERS)' 

piberry-sdcard: update-local-inputs update-index
	sudo $(NIX) build .#nixosConfigurations.piberry.config.system.build.images.sd-card

tauberry: update-local-inputs update-index
	sudo nixos-rebuild --max-jobs 0 switch --flake .#tauberry \
		$(BUILDER_OPTS) \
		--builders '$(BUILDERS)' \
		$(NOM)

tauberry-sdcard: update-local-inputs update-index
	sudo $(NIX) build .#nixosConfigurations.tauberry.config.system.build.images.sd-card

airberry: update-local-inputs update-index
	sudo darwin-rebuild switch \
		$(BUILDER_OPTS) \
		--option builders '$(BUILDERS)' \
		--max-jobs 0 \
		--flake .#airberry 

miniberry: update-local-inputs update-index
	sudo darwin-rebuild switch \
		--flake .#miniberry \
		--option builders '$(BUILDERS)'
		--option builders-use-substitutes true \
		--option always-allow-substitutes true

bootstrap-weirdfi.sh: update-local-inputs update-index
	$(NIX) run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/weirdfi.sh-cax11-4gb/hardware-configuration.nix --flake .#weirdfish-cax11-4gb --target-host "root@weirdfi.sh"

bootstrap-publicproxy: update-local-inputs update-index
	$(NIX) run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/publicproxy-cax11-4gb/hardware-configuration.nix --flake .#publicproxy-cax11-4gb --target-host "root@publicproxy"

deploy: update-local-inputs update-index
ifeq ($(HOSTNAME),hyperberry)
	# build locally
	deploy $(HOST) \
		--skip-checks \
		--skip-offline \
		--fast-connection true \
		--rollback-succeeded false \
		-- \
		$(BUILDER_OPTS) \
		--max-jobs 16 \
		--builders '$(BUILDERS_HB)'
else
	# build remotely
	deploy $(HOST) \
		--skip-checks \
		--skip-offline \
		--fast-connection false \
		--rollback-succeeded false \
		-- \
		$(BUILDER_OPTS) \
		--builders '$(BUILDERS)' \
		--max-jobs 0 \
		$(NOM) 
endif

weirdfi.sh:
	HOST=.#weirdfish-cax11-4gb make deploy 

publicproxy:
	HOST=.#publicproxy-cax11-4gb make deploy 

# Update flake inputs and lock file
update:
	$(NIX) flake update
