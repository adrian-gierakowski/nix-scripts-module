{
  pkgs,
  config,
  lib,
  name,
  ...
}:
let
  inherit (lib) mkOption types;
  internalOptions = builtins.mapAttrs (_: value: mkOption (value // { internal = true; }));
  stringCoercible = types.oneOf [
    types.str
    types.package
    types.path
  ];
in
{
  options = {
    description = mkOption {
      description = "Optinoal description of what the script does. Used as meta.description of the produced package.";
      type = types.nullOr types.str;
      default = null;
    };
    text = mkOption {
      description = "The shell script's text, not including a shebang.";
      type = types.str;
    };
    runtimeInputs = mkOption {
      description = "Inputs to add to the shell script's `$PATH` at runtime.";
      type = types.listOf (
        types.oneOf [
          types.str
          types.package
        ]
      );
      default = [ ];
    };
    runtimeEnv = mkOption {
      description = "Extra environment variables to set at runtime.";
      type = types.nullOr (
        types.oneOf [
          stringCoercible
          (types.attrsOf stringCoercible)
          (types.listOf stringCoercible)
        ]
      );
      default = null;
    };
    derivationArgs = mkOption {
      description = "Extra arguments to pass to `stdenv.mkDerivation`.";
      type = types.attrsOf types.raw;
      default = { };
    };
    extraWriteShellApplicationArgs = mkOption {
      description = "Attribute set passed to writeShellApplication for arguments not covered by typed options.";
      type = types.attrsOf types.raw;
      default = { };
    };
    dir = mkOption {
      description = "Directory from which script file should be loaded.";
      type = types.nullOr (types.coercedTo types.path toString types.str);
      default = null;
    };
  }
  // (internalOptions {
    package = {
      type = types.package;
      description = "Output of script builder: writeShellApplication.";
    };
    exe = {
      type = types.str;
      description = "String contaning path to executable within `outputs.package`.";
    };
    # The purpose of remaining options is to make the top level config interchangeable
    # with config.package when interacting with `nix eval|bulid|run` or toString, so
    # that `scripts.my-script` can be used instead of `scripts.my-script.package`.
    drvPath.type = types.str;
    meta.type = types.attrsOf types.raw;
    name.type = types.str;
    outPath.type = types.str;
    outputName.type = types.str;
    type.type = types.enum [ "derivation" ];
  });
  config = {
    text = lib.mkIf (config.dir != null) (
      lib.mkDefault (builtins.readFile (config.dir + "/${config.name}.sh"))
    );
    package = pkgs.writeShellApplication (
      config.extraWriteShellApplicationArgs
      // {
        inherit (config)
          text
          runtimeInputs
          runtimeEnv
          derivationArgs
          ;
        inherit name;
      }
      // (lib.optionalAttrs (config.description != null) {
        meta = {
          inherit (config) description;
        };
      })
    );
    exe = lib.getExe config.package;
    drvPath = config.package.drvPath;
    meta = config.package.meta;
    name = config.package.name;
    outPath = config.package.outPath;
    outputName = config.package.outputName;
    type = "derivation";
  };
}
