{
  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";
  
  outputs = { self, nixpkgs }: {
    nixosConfigurations.gamestation = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Specify the full path to your configuration
        ./configuration.nix
        ./hardware-configuration.nix  # Add this explicitly
      ];
    };
  };
}