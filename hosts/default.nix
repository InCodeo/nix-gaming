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

        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mihai.imports = [
              ../home/default.nix  # Basic user config
              ../home/editors/helix  # Editor config
              ../home/programs  # Basic programs
              ../home/programs/games  # Gaming-specific programs
              ../home/programs/wayland  # Wayland/Hyprland config
            ];
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}