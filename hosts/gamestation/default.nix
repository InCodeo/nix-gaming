{ config, pkgs, lib, ... }: {
  # Disable all default NVIDIA configuration
  disabledModules = [ "hardware/video/nvidia.nix" ];

  # Then configure exactly what we want
  hardware.nvidia = {
    open = lib.mkForce false;
    nvidiaSettings = true;
    # Only allow legacy driver
    package = lib.mkForce (lib.hiPrio pkgs.linuxPackages_6_1.nvidia_x11_legacy470);
    modesetting.enable = true;
    prime.sync.enable = false;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_1;
    blacklistedKernelModules = [ "nouveau" "nvidia_drm" "nvidia_modeset" "nvidia" ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    # Add this after initial module load
    initrd.kernelModules = [ "nvidia" ];
    extraModprobeConfig = ''
      options nvidia NVreg_RegisterForACPIEvents=1
    '';
  };

  # Only allow specific version in nixpkgs
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    nvidia.acceptLicense = true;
    # Prevent other NVIDIA packages from being built
    packageOverrides = pkgs: {
      linuxPackages_6_1 = pkgs.linuxPackages_6_1.override {
        nvidia_x11 = lib.mkForce null;
      };
    };
  };

  # Make sure X.org knows to use our specific driver
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
}