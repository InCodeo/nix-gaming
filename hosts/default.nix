{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    mod = "${self}/system";
    
    # get these into the module system
    specialArgs = {inherit inputs self;};
  in {
    # Your new gamestation configuration
    gamestation = nixosSystem {
      inherit specialArgs;
      modules = [
        ./gamestation
        "${mod}/core"
        "${mod}/core/boot.nix"

        "${mod}/programs/gamemode.nix"
        "${mod}/programs/games.nix"
        "${mod}/programs/home-manager.nix"
        
        # Graphical environment 
        "${mod}/programs/hyprland.nix"

        # Network features
        "${mod}/network/default.nix"
        "${mod}/network/syncthing.nix"

        # Services
        "${mod}/services/pipewire.nix"

        {
          home-manager = {
            users.mihai.imports = [
              ../.
              "${self}/home/profiles/io"  # Reusing io's home config
            ];
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}