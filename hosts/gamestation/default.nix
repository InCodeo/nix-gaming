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
      
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      
      desktopManager.plasma6.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    glxinfo
    vulkan-tools
    

  ];

  programs.seahorse.enable = lib.mkForce false;

  # Disable services that might conflict
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
}