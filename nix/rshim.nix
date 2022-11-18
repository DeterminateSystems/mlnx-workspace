{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "rshim";
  version = "2.0.6-18";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      # NOTE: this is actually from nixpkgs proper
      pciutils
      libusb1
      fuse
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src

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

    runHook postInstall
  '';
}
