{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "collectx";
  version = "1.11.0-6225698";

  src = ../nv + "/${pname}_${version}-ubuntu20.04-x86_64-clxapi.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      # NOTE: this is actually from nixpkgs proper
      openssl_1_1
      zlib
      gcc-unwrapped.lib
      curl
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    mv ./src/opt/mellanox/collectx/lib ./src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv src/* $out

    tester() {
      dir="$1"
      test -d "$1" && (mv "$1"/* "$1"/.. && rmdir "$1") || (return 0)
    }

    tester $out/usr
    tester $out/lib/x86_64-linux-gnu
    test -d $out/lib && chmod +x $out/lib/*
    test -d $out/lib && chmod +x $out/lib/*/*

    runHook postInstall
  '';
}
