{
  inputs,
  lib,
  globals,
  prebuiltPackages,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.config.by) keys;
  inherit (globals) FLAKE_ROOT;
in
{
  flake.lib.darwin.mkMicroVM = 
    {
      hostName,
      system, # must be aarch64-linux
      extraModules,
      microvmConfig ? { },
      tags ? [ ],
      enable ? false,
    } @args: config':

    let
      flat = lib.lists.flatten extraModules;
      aspects = builtins.filter (a: builtins.isAttrs a && a ? "_type" && a._type == "aspect") flat;

      baseAspects = with flake.modules; lib.lists.flatten [
        (with flake.tags; flake.lib.use [
          flake-default
          nixos-base
        ])
        nixos.authorized-keys
      ];
      baseModules = [
        inputs.microvm.nixosModules.microvm
        # User config
        config'
        {
          by.presets.authorized-keys = {
            groups = [
              {
                keys = keys.ssh.hosts.miniberry.paths ++ keys.ssh.groups.privileged.paths;
                users = [ "root" ];
              }
            ];
          };
        }
      ];

      nixosAspects = builtins.filter (a: a.class == "nixos") (baseAspects ++ aspects);
      nixosModules = baseModules ++ (lib.lists.subtractLists aspects flat);

      microvmDefaults = {
        networking = {
          ipSubnet = "24";
          gateway = "10.0.0.1";
        };
      };
    in

    flake.lib.darwin.mkAspect tags 
    ({
      config,
      pkgs,
      ...
    }:
    let
      pkgs' = if ("pkgs" ? args) then args.pkgs else prebuiltPackages.${system};
      specialArgs' = if ("specialArgs" ? args) then args.specialArgs else { };
      specialArgs = specialArgs' // { inherit inputs; };
      
      vm = lib.recursiveUpdate microvmDefaults microvmConfig;

      microvm-home = "/var/lib/microvms/${hostName}";
      microvm-host-key = "${microvm-home}/ssh-host-keys/ssh_host_ed25519_key";
      vfkit-sock = "/tmp/${hostName}-vfkit.sock";

      primaryModule = ({ config, ... }: {
        microvm = {
          hypervisor = lib.mkForce "vfkit";
          vmHostPackages = prebuiltPackages.aarch64-darwin;
          vfkit = {
            rosetta = {
              enable = true;
              install = true;
            };
            extraArgs = [
              "--device"
              "virtio-net,unixSocketPath=${vfkit-sock},mac=5a:94:ef:e4:0c:ee"
              # vmnet-helper requires fd=4
              #"virtio-net,fd=4,mac=${vm.networking.macAddress}"
            ];
          };
          volumes = [
            {
              image = "${microvm-home}/rw-store.img";
              mountPoint = "/nix/.rw-store";
              size = 1024 * 32;
            }
          ];
          shares = [
            #{
            #  source = "/nix/store";
            #  mountPoint = "/nix/.ro-store";
            #  tag = "ro-store";
            #  proto = "virtiofs";
            #  readOnly = true;
            #}
            {
              source = "${microvm-home}/ssh-host-keys";
              mountPoint = "/var/lib/ssh-host-keys";
              tag = "ssh-host-keys";
              proto = "virtiofs";
            }
            {
              source = "${microvm-home}/journal";
              mountPoint = "/var/log/journal";
              tag = "journal";
              proto = "virtiofs";
            }
            {
              source = "/var/lib/microvms/${hostName}/tailscale";
              mountPoint = "/var/lib/tailscale";
              tag = "tailscale";
              proto = "virtiofs";
            }
            {
              source = "/var/lib/microvms/${hostName}/root-home";
              mountPoint = "/root";
              tag = "root-home";
              proto = "virtiofs";
            }
          ];
          writableStoreOverlay = "/nix/.rw-store";
          storeDiskType = "squashfs";
        };

        networking = {
          inherit hostName;
          firewall = {
            enable = lib.mkDefault true;
            allowPing = lib.mkDefault true;
            allowedTCPPorts = [ 22 ];
          };
        };

        nix.nixPath = [
          "nixpkgs=${pkgs'.path}"
        ];

        nix.optimise.automatic = lib.mkForce false;

        services.openssh = {
          enable = lib.mkDefault true;
          settings = {
            PasswordAuthentication = lib.mkDefault false;
            PermitRootLogin = lib.mkDefault "prohibit-password";
          };
          # Due to permission issues we have to do this manually
          generateHostKeys = false;
          hostKeys = [
            {
              path = "/var/lib/ssh-host-keys/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];
        };

        system.activationScripts.postActivation.text = ''
          chown root:root /
          chmod 755 /
        '';

        # This allows the Agenix module to decrypt secrets during early boot.
        fileSystems."/var/lib/ssh-host-keys".neededForBoot = true;

        age.secrets.tailscale-auth-key = lib.mkIf (vm.tailscale.enable && vm.tailscale.autologin) {
          file = "${FLAKE_ROOT}/secrets/agenix/tailscale/guests/${hostName}.age"; 
          mode = "0440"; 
        };

        services.tailscale = lib.mkIf (vm.tailscale.enable) {
          enable = true;
          authKeyFile = lib.mkIf (vm.tailscale.autologin) config.age.secrets.tailscale-auth-key.path;
        };

        system.stateVersion = lib.mkDefault "24.11";
      });

      modules =
        [ primaryModule ]
        ++ nixosModules
        ++ (builtins.map (aspect: aspect._module) (nixosAspects));

      microvm = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        inherit specialArgs modules;
      };
      microvm-runner = microvm.config.microvm.declaredRunner;
      #service-script = pkgs.writeShellScript "${hostName}-runner" ''
      #  rm -f ${vfkit-sock}

      #  ${lib.getExe pkgs.gvproxy} \
      #    --ssh-port 2222 \
      #    --listen-vfkit "unixgram://${vfkit-sock}" \
      #    >/tmp/${hostName}-gvproxy.log 2>&1 &
      #  GVPROXY_PID=$!
      #  trap 'kill $GVPROXY_PID' EXIT

      #  until [ -S ${vfkit-sock} ]; do sleep 1; done;

      #  ${lib.getExe pkgs.unixtools.script} -q "/tmp/${hostName}.log" ${lib.getExe microvm-runner} &

      #  wait -n
      #'';
      service-script = pkgs.writeShellScript "${hostName}-runner" ''
        rm -rf ${vfkit-sock}

        ln -sfn ${microvm-runner} ${microvm-home}/current
        ${pkgs.external.vmnet-helper}/bin/vmnet-helper \
          --socket ${vfkit-sock} \
          --network shared &
        BROKER_PID=$!
        trap 'kill $BROKER_PID' EXIT

        until [ -S ${vfkit-sock} ]; do sleep 1; done
        
        ${lib.getExe pkgs.unixtools.script} -q /tmp/${hostName}.log ${lib.getExe microvm-runner} &

        wait -n
      '';
    in
    {
      # maybe move this out
      config.launchd.daemons.vmnet-broker = {
        command = "${pkgs.external.vmnet-broker}/bin/vmnet-broker";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          # ?
          MachServices."com.github.nirs.vmnet-broker" = true;
          EnableTransactions = true;
        };
      };

      config.launchd.daemons.${hostName} = {
        command = service-script;
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          WorkingDirectory = microvm-home;
          StandardOutPath = "/tmp/${hostName}.stdio";
          StandardErrorPath = "/tmp/${hostName}.stderr";
        };
      };

      config.system.activationScripts.postActivation.text = lib.mkAfter ''
        # TODO permissions
        mkdir -p "${microvm-home}"
        mkdir -p "${microvm-home}/ssh-host-keys"
        mkdir -p "${microvm-home}/journal"
        mkdir -p "${microvm-home}/tailscale"
        mkdir -p "${microvm-home}/root-home"

        if [ ! -f "${microvm-host-key}" ]; then
          ssh-keygen -t ed25519 -f ${microvm-host-key} -N ""
        fi

        chown -R root ${microvm-home}
        chmod -R 700 ${microvm-home}
      '';
    });
}
