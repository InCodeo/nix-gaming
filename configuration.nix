{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  users.users.dev = {
    isNormalUser = true;
    description = "dev";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  services.getty.autologinUser = "dev";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core utilities
    wget vim git curl
    # Shell
    zsh oh-my-zsh
    # Network tools
    tailscale
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
      X11Forwarding = false;
    };
    ports = [22];
  };
  services.tailscale.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.trustedInterfaces = [ "tailscale0"];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    # ZSH Configuration
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "docker" "sudo" ];
      theme = "robbyrussell";
    };
    shellInit = ''
      ${builtins.replaceStrings ["\r\n"] ["\n"] (builtins.readFile ./functions.zsh)}
      ${builtins.replaceStrings ["\r\n"] ["\n"] (builtins.readFile ./client-functions.zsh)}
    '';
  };

  # Set ZSH as default shell for root
  users.defaultUserShell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

  system.stateVersion = "24.05"; 

}
