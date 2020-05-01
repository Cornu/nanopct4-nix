{ stdenv, writeText, callPackage, runCommand, buildUBoot, ubootTools }:

# https://github.com/archlinuxarm/PKGBUILDs/pull/1728/files#diff-cc86a94e80a80a0b73542e83024e6bfdR29

let 
  uboot = buildUBoot {
    defconfig = "nanopc-t4-rk3399_defconfig";
    extraMeta.platforms = ["aarch64-linux"];
    #BL31="${armTrustedFirmwareRK3399}/bl31.elf";
    filesToInstall = [ "u-boot-dtb.bin" ];
  };

  rk3399trust = writeText "rk3399trust.ini" ''
    [VERSION]
    MAJOR=1
    MINOR=0
    [BL30_OPTION]
    SEC=0
    [BL31_OPTION]
    SEC=1
    PATH=${rkbin}/bin/rk33/rk3399_bl31_v1.33.elf
    ADDR=0x00010000
    [BL32_OPTION]
    SEC=0
    [BL33_OPTION]
    SEC=0
    [OUTPUT]
    PATH=trust.img
  '';

  rkbin = callPackage ./rkbin.nix {};

  rkUbootTools = callPackage ./rkuboot.nix {};
in
runCommand "rkboot" {} ''
  mkdir -p $out/
  ${ubootTools}/bin/mkimage -n rk3399 -T rksd -d ${rkbin}/bin/rk33/rk3399_ddr_933MHz_v1.24.bin $out/idbloader.img
  cat ${rkbin}/bin/rk33/rk3399_miniloader_v1.24.bin >> $out/idbloader.img

  ${rkUbootTools}/bin/loaderimage --pack --uboot ${uboot}/u-boot-dtb.bin $out/uboot.img
  cp ${uboot}/u-boot-dtb.bin $out

  ${rkUbootTools}/bin/trust_merger ${rk3399trust}
  cp trust.img $out
''
