{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.tofi;

in {
  meta.maintainers = [ hm.maintainers.henrisota ];

  options.programs.tofi = {
    enable = mkEnableOption "Tofi, a tiny dynamic menu for Wayland";

    package = mkPackageOption pkgs "tofi" { nullable = true; };

    settings = mkOption {
      type = with types;
        let primitive = either (either str int) bool;
        in attrsOf primitive;
      default = { };
      example = literalExpression ''
        {
          background-color = "#000000";
          border-width = 0;
          font = "monospace";
          height = "100%";
          num-results = 5;
          outline-width = 0;
          padding-left = "35%";
          padding-top = "35%";
          result-spacing = 25;
          width = "100%";
        }
      '';
      description = ''
        Settings to be written to the Tofi configuration file.

        See <https://github.com/philj56/tofi/blob/master/doc/config>
        for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [ (hm.assertions.assertPlatform "programs.tofi" pkgs platforms.linux) ];

    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."tofi/config" = mkIf (cfg.settings != { }) {
      text = let
        renderedSettings = generators.toINIWithGlobalSection { } {
          globalSection = cfg.settings;
        };
      in removeSuffix "\n\n" ''
        # Generated by Home Manager.

        ${renderedSettings}
      '';
    };
  };
}
