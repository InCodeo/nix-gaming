{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    
    kernelModules = ["nvidia"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  };

  # Essential NVIDIA configuration - modified for GTX 970
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidia_x11_legacy470;  # Using legacy driver
    modesetting.enable = true;
    prime.sync.enable = false;  # Disable PRIME as this is a desktop
    powerManagement.enable = false;  # Desktop GPU doesn't need power management
  };

  # Allow unfree packages (needed for NVIDIA)
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "gamestation";

  services = {
    fstrim.enable = true;
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      displayManager.gdm.wayland = true;  # Enable Wayland
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.full  # Updated from nvtop
    glxinfo  # For debugging GPU issues
    vulkan-tools  # For testing Vulkan support
  ];
}