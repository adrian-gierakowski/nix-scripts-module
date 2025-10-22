{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) types;
in
{
  options.perSystem = mkPerSystemOption (
    {
      config,
      lib,
      ...
    }:
    {
      options.scriptsDefaults = lib.mkOption {
        type = types.deferredModule;
        description = "Default configuration applied to all scripts.";
        default = { };
      };

      imports = [
        (lib.modules.importApply ./scripts.nix config.scriptsDefaults)
      ];

      config.packages = config.scripts;
    }
  );
}
