{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "bfb2image";
  version = "1.0.0";

  src = ../nv + "/${pname}_${version}_all.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      python3
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src

    runHook postUnpack
  '';

  # NOTE: It drops things in /opt/mellanox/doca... I dunno how to sort it, so
  # I'm leaving it there for now.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv src/* $out

    tester() {
      dir="$1"
      test -d "$1" && (cp -r "$1"/* "$1"/.. && rm -r "$1") || (return 0)
    }

    tester $out/usr

    runHook postInstall
  '';
}
