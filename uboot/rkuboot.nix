{ stdenv, fetchFromGitHub, openssl }:

stdenv.mkDerivation {
  pname = "rockchip-uboot-tools";
  version = "2020-03-30";

  src = fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "u-boot";
    rev = "505eebf24e153630f5a3e0ec232ffda67bf48e9e";
    sha256 = "0fdidcpdpk26fsmsbds1fvdizqcrd575m9md2gngg0h5yhnb88xf";
  };

  nativeBuildInputs = [
    openssl
  ];

  configurePhase = ''
    make rk3399_defconfig
  '';

  buildPhase = ''
    make tools
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp tools/loaderimage tools/trust_merger $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/rockchip-linux/uboot";
    license = licenses.gpl2;
  };
}
