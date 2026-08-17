{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "26.11";

  boot = {
    kernelParams = [ "fbcon=rotate:1" ];
    initrd.systemd.emergencyAccess = true;
    # WARN: We use UKI!
    loader.external = {
      enable = true;
      installHook = pkgs.writeShellScript "no-bootloader" "";
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.nix = {
    password = "nix";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  networking = {
    networkmanager.enable = true;
    wlanInterfaces.wld0 = {
      device = "wld0";
      mac = "6e:69:78:6f:73:21";
    };
  };
}
