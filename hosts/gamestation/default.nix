{ config, pkgs, lib, ... }: {
  # First, disable the default NVIDIA driver
  hardware.nvidia.package = lib.mkForce null;

  # Then configure only what we need
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    # Force the legacy package
    package = lib.mkForce config.boot.kernelPackages.nvidia_x11_legacy470;
    modesetting.enable = true;
    prime.sync.enable = false;
    powerManagement.enable = false;
    forceFullCompositionPipeline = true;
  };

  # Make sure we're using consistent kernel packages
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_1;
    kernelModules = [ "nvidia" ];
    extraModulePackages = with config.boot.kernelPackages; [ 
      (lib.mkForce nvidia_x11_legacy470)
    ];
  };

  # Also explicitly disable the newer driver in nixpkgs
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    nvidia.acceptLicense = true;
    packageOverrides = pkgs: {
      linuxPackages_6_1 = pkgs.linuxPackages_6_1.override {
        nvidia_x11 = null;
      };
    };
  };
}