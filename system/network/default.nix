# networking configuration
{ pkgs, ... }: {
  networking = {
    # use quad9 with DNS over TLS
    nameservers = ["9.9.9.9#dns.quad9.net"];
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      settings.UseDns = true;
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };

    # DNS resolver
    resolved = {
      enable = true;
      dnsovertls = "opportunistic";
    };

    dbus = {
      enable = true;
      packages = [ pkgs.dbus ];
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}