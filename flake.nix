{
  description = "Define collections of executable scripts with minimal boilerplate.";
  outputs = _: {
    flakeModule = ./nix/flake-module.nix;
  };
}
