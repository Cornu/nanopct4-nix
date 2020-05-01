# nanopct4-nix
NixOS on Nano PC T4

## Build uboot

`$ NIXPKGS_ALLOW_UNFREE=1 nix-build -A pkgs.uBootNanoPcT4`

## Build Image

`$ nix-build sd-image-aarch64-rk3399.nix -A config.system.build.sdImage`
