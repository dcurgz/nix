{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.by.programs.quickshell;
in
{
  options.by.programs.quickshell = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable QuickShell program.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.quickshell;
      description = "The QuickShell package to use.";
    };
  };

  config.by.programs.quickshell =
  let
    qs-wrapped = pkgs.runCommand "quickshell-wrapped" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin
      makeWrapper ${cfg.package}/bin/qs $out/bin/qs \
      --set LD_LIBRARY_PATH "${pkgs.fontconfig.lib}/lib" \
      --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
      --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
      --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
      --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
      --prefix PATH : ${lib.makeBinPath [ pkgs.fd pkgs.coreutils ]}
    '';
  in
  {
    enable = cfg.enable;
    package = mkForce qs-wrapped;
  };
}
