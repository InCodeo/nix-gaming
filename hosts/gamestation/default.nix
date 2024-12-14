{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use GRUB for BIOS boot
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/nvme0n1";
      efiSupport = false;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    nvidia.acceptLicense = true;
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_1;
    kernelModules = [ "nvidia" ];
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11_legacy470 ];
  };

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    package = lib.mkForce config.boot.kernelPackages.nvidia_x11_legacy470;
    modesetting.enable = true;
    prime.sync.enable = false;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };

  networking = {
    hostName = "gamestation";
    interfaces.enp4s0.useDHCP = true;
  };

  services = {
    fstrim.enable = true;
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      
      # Change from GDM to SDDM
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      
      # Enable Plasma 6
      desktopManager.plasma6.enable = true;
    };
  };

  # Add common KDE/Plasma packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    glxinfo
    vulkan-tools
    
    # Plasma/KDE additions
    libsForQt6.qt6.qtwayland
    plasma6Packages.kate
    plasma6Packages.konsole
    plasma6Packages.plasma-workspace
    plasma6Packages.plasma-desktop
    plasma6Packages.plasma-nm
    plasma6Packages.plasma-pa
  ];

  # Disable services that might conflict
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
}