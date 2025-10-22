{
  description = "Define collections of executable scripts with minimal boilerplate.";
  outputs = _: {
    flakeModule = ./nix/flake-module.nix;

    templates.default = {
      description = "Example flake using nix-scripts-module";
      path = builtins.path {
        path = ./example;
        filter = path: _: baseNameOf path == "flake.nix";
      };
    };
  };
}
