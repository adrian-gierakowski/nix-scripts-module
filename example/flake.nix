{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-scripts-module.url = "github:adrian-gierakowski/nix-scripts-module";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-scripts-module.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          lib,
          ...
        }:
        {
          scriptsDefaults = {
            dir = ./scripts;
            derivationArgs = {
              preferLocalBuild = lib.mkDefault true;
              allowSubstitutes = lib.mkDefault false;
            };
          };
          scripts = {
            # Simplest way to define a script with just a in inline bash snippet.
            hello = ''echo Hello "''${1:-scripts}!"'';
            # Object form with just `text` is equivalent to the above, but it
            # allows to set other properties.
            hello-no-shorthand = {
              text = ''echo Hello "''${1:-scripts}!"'';
              description = "Equivalent to the hello script, but with description!";
            };
            # Inline script depend on other scripts via string interpolation.
            # `scripts.hello.exe`  is a shortcut for: `lib.getExe config.scripts.hello`
            hello-interpolated-deps = "${config.scripts.hello.exe} 'interpolated deps'";
            # If text is not defined, script will be loaded from file at: `${dir}/name.sh`
            # (defined for all scripts with scriptsDefaults.dir above).
            hello-from-file = {
              # Deps added to PATH, since we can simply interpolate as above.
              # NOTE: this can also be used with incline scripts, if you don't like
              # interpolation.
              runtimeInputs = [
                config.scripts.hello
              ];
              description = "Example of scripts loaded from file.";
            };
          };
        };
    };
}
