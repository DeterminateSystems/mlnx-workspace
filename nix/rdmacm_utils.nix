{ pkgs
, stdenv
}:
stdenv.mkDerivation rec {
  pname = "rdmacm-utils";
  version = "58mlnx43-1.58101";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      dpkg
      tree
      perl
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r src/* $out

    runHook postInstall
  '';
}
