{
  pkgs ? import (builtins.fetchTarball "channel:nixos-20.03") {
    overlays = [
      (import ./overlay.nix)
    ];
  }
}: pkgs 

#let
#  pkgs' = if builtins.currentSystem == "aarch64-linux"
#    then pkgs
#    else pkgs.pkgsCross.aarch64-multiplatform
#  ;
#in
#{
#  pkgs = pkgs';
#}
