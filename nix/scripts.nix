# This is meant to be imporved using lib.importApply
defaults:
{
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (lib) types;
in
{
  options = {
    scripts =
      let
        coerceStringToAttrs = value: if builtins.isString value then { text = value; } else value;
      in
      lib.mkOption {
        description = ''
          An attrset of scripts built with writeShellApplication. Name of the attrs is used as name
          argument of writeShellApplication.
          The value can be either strings, in which case it is mapped to `text` argument of writeShellApplication,
          or an attrset, which allows additional arguments to be sutomized.
          If text is not set in the attrset case, a file at path `''${dir}/''${name}.sh` is loaded as text.
        ''
        + (lib.optionalString (defaults.dir or null != null) ''
          If text is not set in the attrset case, a file at path `''${${toString defaults.dir}}/''${name}.sh` is loaded as text.
        '');
        type = types.lazyAttrsOf (
          types.coercedTo types.str coerceStringToAttrs (
            types.submoduleWith {
              inherit specialArgs;
              modules = [
                {
                  imports = [
                    ./script.nix
                    defaults
                    { _module.args.pkgs = pkgs; }
                  ];
                }
              ];
            }
          )
        );
        default = { };
      };
  };
}
