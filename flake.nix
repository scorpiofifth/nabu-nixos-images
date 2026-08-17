{
  description = "A flake to build NixOS images for Xiaomi Pad 5(nabu)";

  inputs = {
    # NOTE: it is better to use the repo's nixpkgs,
    # cuz it will be tough to build the kernel
    nixpkgs.follows = "nabu/nixpkgs";
    nabu.url = "github:scorpiofifth/xiaomi-nabu-flake";
  };

  outputs =
    flakes@{
      self,
      nixpkgs,
      ...
    }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      osConfig = nixpkgs.lib.nixosSystem {
        # NOTE: this NixOS config is designed for build the installer
        # which should be as small as possible, after that re-build
        # the system on the target deviece
        specialArgs = { inherit flakes; };
        modules = [ ./nixos/configuration.nix ];
      };
    in
    {
      nixosConfigurations.default = osConfig;
      packages.${system}.default = osConfig.config.system.build.uki;
      devShells.${system}.default = (
        pkgs.mkShell rec {
          configBuild = osConfig.config.system.build.toplevel;
          binPath = lib.makeBinPath (
            with pkgs;
            [
              osConfig.config.system.build.nixos-install
              e2fsprogs
              nix
              nixos-enter
            ]
            ++ stdenv.initialPath
          );
          closureInfo = pkgs.closureInfo {
            rootPaths = [
              channelSources
              configBuild
            ];
          };
          channelSources = pkgs.runCommand "nixos-${osConfig.config.system.nixos.version}" { } ''
            mkdir -p $out
            cp -prd ${(lib.cleanSource pkgs.path).outPath} $out/nixos
            chmod -R u+w $out/nixos
            if [ ! -e $out/nixos/nixpkgs ]; then
              ln -s . $out/nixos/nixpkgs
            fi
            rm -rf $out/nixos/.git
            echo -n ${osConfig.config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
          '';
        }
      );
    };
}
