{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    
    specialArgs = {inherit inputs self;};
  in {
    gamestation = nixosSystem {
      inherit specialArgs;
      modules = [
        ./gamestation
        { imports = (import ../system).desktop; }
        
        ../system/programs/gamemode.nix
        ../system/programs/games.nix

        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mihai.imports = [
              ../home/default.nix
              ../home/editors/helix
              # Let's be specific about which programs we want
              ../home/programs/browsers/chromium.nix
              ../home/programs/browsers/firefox.nix
              ../home/programs/gtk.nix
              ../home/programs/qt.nix
              ../home/programs/games
              # ../home/programs/wayland/hyprland
            ];
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  };
}