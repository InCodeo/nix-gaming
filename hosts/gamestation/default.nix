{
  pkgs,
  lib,
  config,  # Added this
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../io/powersave.nix
  ];

  boot = {
    # Using latest kernel for best hardware support
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    
    kernelModules = ["nvidia"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  };

  # Essential NVIDIA configuration
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidia_x11;
    modesetting.enable = true;
  };

  networking.hostName = "gamestation";

  services = {
    # for SSD/NVME
    fstrim.enable = true;

    # X11 support for NVIDIA
    xserver.videoDrivers = ["nvidia"];
  };

  environment.systemPackages = with pkgs; [
    nvtop  # NVIDIA process monitor
  ];
}