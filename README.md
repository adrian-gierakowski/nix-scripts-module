# nix-scripts-module

Define collections of executable scripts with minimal boilerplate.

# usage

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # add input
    nix-scripts-module.url = "github:adrian-gierakowski/nix-scripts-module";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # import flakeModule
        inputs.nix-scripts-module.flakeModule
      ];

      perSystem = {
        # define scripts
        scripts = {
          my-script = ''echo Hello "$1"'';
        };
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
}

```

All scripts are automatically added to you flakes outputs.packages, so you can run then like this:

```sh
nix run .#my-script
```

For full example see [example](/example/flake.nix).

# template

To initialize a project from example template:

```sh
nix flake init -t github:adrian-gierakowski/nix-scripts-module
```

