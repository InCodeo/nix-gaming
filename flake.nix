# flake.nix
{
  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations.gamestation = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}