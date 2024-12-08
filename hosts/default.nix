{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    
    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    # Your new gamestation configuration
    gamestation = nixosSystem {
      inherit specialArgs;
      modules = [
        ./gamestation
        # Import desktop modules directly
        { imports = (import ../system).desktop; }
        
        # Gaming-specific modules
        ../system/programs/gamemode.nix
        ../system/programs/games.nix

        # Home-manager config
        {
          home-manager = {
            users.mihai.imports = [
              "${self}/home/profiles/io"
            ];
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}