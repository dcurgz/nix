{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.globals) FLAKE_ROOT;
in

{
  flake.modules.nixos.hyperberry-network = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      by = config.by.host-constants;
    in
    {
      age.secrets.wg0-key = {
        file = "${FLAKE_ROOT}/agenix-secrets/agenix/wireguard/001-key.age";
      };

      networking = {
        hostName = "hyperberry";
        enableIPv6 = true;
        # ...nameservers are handled by the DNS aspect.
        firewall = {
          enable = true;
          checkReversePath = "loose";
          allowedTCPPorts = [
            22
          ];
          interfaces."br0".allowedTCPPorts = [
            11434 # ollama
          ];
        };
        interfaces."${by.hardware.interfaces.ethernet}" = {
          ipv4.addresses = [{
            address = "192.168.0.10";
            prefixLength = 24;
          }];
        };
        defaultGateway = {
          address = "192.168.0.1";
          interface = by.hardware.interfaces.ethernet;
        };
      };

      systemd.network.enable = true;
      networking.useNetworkd = true;

      networking.nftables = {
        enable = true;
        tables."hyperberry" = {
          family = "inet";
          content = ''
            chain forward {
              type filter hook forward priority -1; policy accept;
              # Block br1 from reaching ethernet directly (must use WireGuard)
              iifname "br1" oifname "${by.hardware.interfaces.ethernet}" drop
            }
          '';
        };
      };

      networking.wg-quick.interfaces."wg0" =
        let
          ip = "${pkgs.iproute2}/bin/ip";
          nft = lib.getExe pkgs.nftables;
          git-secrets = config.by.git-secrets.wireguard."001";
          br1-subnet = "10.0.9.0/24";
        in
        {
          table = "off";
          inherit (git-secrets) address;
          peers = [
            {
              inherit (git-secrets) endpoint publicKey;
              allowedIPs = [ "0.0.0.0/0" "::/0" ];
            }
          ];
          privateKeyFile = config.age.secrets.wg0-key.path;
          postUp = ''
            # Policy routing: send br1 subnet traffic via wg0
            ${ip} route add ${br1-subnet} dev br1 table 51820
            ${ip} route add default dev wg0 table 51820
            ${ip} rule add from ${br1-subnet} table 51820 priority 100

            # Forward br1 traffic through wg0
            ${nft} add table inet wg-br1
            ${nft} add chain inet wg-br1 forward '{ type filter hook forward priority 0; policy accept; }'
            ${nft} add rule inet wg-br1 forward iifname "br1" oifname "wg0" accept
            ${nft} add rule inet wg-br1 forward iifname "wg0" oifname "br1" ct state established,related accept
            ${nft} add chain inet wg-br1 postrouting '{ type nat hook postrouting priority 100; }'
            ${nft} add rule inet wg-br1 postrouting oifname "wg0" ip saddr ${br1-subnet} masquerade
          '';
          postDown = ''
            ${ip} rule del from ${br1-subnet} table 51820 priority 100 || true
            ${ip} route del default dev wg0 table 51820 || true
            ${ip} route del ${br1-subnet} dev br1 table 51820 || true
            ${nft} delete table inet wg-br1
          '';
        };

      # Configure bridge for MicroVMs
      systemd.network.netdevs."br0" = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
        };
      };

      systemd.network.netdevs."br1" = {
        netdevConfig = {
          Name = "br1";
          Kind = "bridge";
        };
      };

      systemd.network.networks."10-add-interfaces-to-br0" = {
        matchConfig.Name = [
          "vm-*"
        ];
        networkConfig = {
          Bridge = "br0";
        };
      };

      systemd.network.networks."20-add-interfaces-to-br1" = {
        matchConfig.Name = [
          "vx-*"
        ];
        networkConfig = {
          Bridge = "br1";
        };
      };

      systemd.network.networks."30-configure-gateway-for-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          Address = [ "10.0.0.1/24" ];
          DHCPServer = true;
          IPv6SendRA = true;
        };
      };

      systemd.network.networks."40-configure-gateway-for-br1" = {
        matchConfig.Name = "br1";
        networkConfig = {
          Address = [ "10.0.9.1/24" ];
          DHCPServer = true;
          IPv6SendRA = true;
        };
      };

      # Allow internet access for VMs
      networking.nat = {
        enable = true;
        externalInterface = by.hardware.interfaces.ethernet;
        internalInterfaces = [ "br0" ];
      };

      services.tailscale = {
        enable = true;
      };
    });
}
