final: super:

let
  inherit (final) callPackage;
in
{
  uBootNanoPcT4 = callPackage ./uboot {};
}
