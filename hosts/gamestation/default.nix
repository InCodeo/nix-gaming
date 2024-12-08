{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Add NVIDIA configuration with broken packages allowed
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    nvidia.acceptLicense = true;
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_1;  # Use a specific kernel version
    
    kernelModules = ["nvidia"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  };

  # NVIDIA configuration for GTX 970
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    # Use the 470 series driver which is known to work with GTX 970
    package = config.boot.kernelPackages.nvidia_x11_legacy470;
    modesetting.enable = true;
    prime.sync.enable = false;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;  # Can help with screen tearing
  };

  networking.hostName = "gamestation";

  services = {
    fstrim.enable = true;
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
      displayManager.gdm.wayland = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    glxinfo
    vulkan-tools
  ];
}