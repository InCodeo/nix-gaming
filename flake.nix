{
  description = "Basic NixOS Config";

  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";  # Use current stable version
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./configuration.nix
      ];
    };
  };
}