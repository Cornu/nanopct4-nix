{ stdenv, fetchFromGitHub, runCommand }:

let 
  src = fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "aae5f990fcf0dd604f7955cca7666b904d48ef09";
    sha256 = "051iw3c68qldzznqdq7a4j9sxhxdvblwn2mn65lrai1dpzzj9yzj";
  };
in
runCommand "rkbin" {
  meta = with stdenv.lib; {
    homepage = "https://github.com/rockchip-linux/rkbin";
    license = licenses.unfreeRedistributable;
  };
} ''
  mkdir -p $out/
  cp -R ${src}/bin $out/
''
