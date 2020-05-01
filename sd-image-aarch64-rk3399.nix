{ config, lib, pkgs, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
  uboot = pkgs.uBootNanoPcT4;
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    ./sd-image.nix
  ];

  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "cma=32M"
    #"console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"

    "console=ttyS2,1500000n8"
    "earlycon=uart8250,mmio32,0xff1a0000" "earlyprintk"

    # The last console parameter will be where the boot process will print
    # its messages. Comment or move abot ttyS2 for better serial debugging.
    "console=tty0"
  ];

  services.mingetty.serialSpeed = [ 1500000 115200 57600 38400 9600 ];

  boot.initrd.availableKernelModules = [
  ];

  # This list of modules is not entirely minified, but represents
  # a set of modules that is required for the display to work in stage-1.
  # Further minification can be done, but requires trial-and-error mainly.
  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"

    # USB / Type-C related modules
    "fusb302"
    "tcpm"
    "typec"
  ];

  sdImage = {
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
    manipulateImageCommands = ''
      (PS4=" $ "; set -x
      dd if=${uboot}/idbloader.img of=$img bs=512 seek=64 conv=notrunc
      dd if=${uboot}/uboot.img of=$img bs=512 seek=16384 conv=notrunc
      dd if=${uboot}/trust.img of=$img bs=512 seek=24576 conv=notrunc
      )
    '';
    compressImage = lib.mkForce false;
  };

  # the installation media is also the installation target,
  # so we don't want to provide the installation configuration.nix.
  installer.cloneConfig = false;
}
