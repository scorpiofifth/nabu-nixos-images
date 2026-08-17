{ flakes, ... }:
{
  imports = [
    flakes.nabu.nixosModules.default
  ];

  nabu = {
    enable = true;
    firstboot.enable = true;
  };

  nixpkgs.hostPlatform = "aarch64-linux";
}
