{
  flake.nixosModules = {
    theme = import ./theme;
    desktop = import ../system;
  };
}