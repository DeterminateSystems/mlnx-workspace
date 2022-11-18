{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "opensm";
  version = "5.13.0.MLNX20221016.10d3954-0.1.58101";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.libopensm

      # NOTE: this is actually from nixpkgs proper
      gcc-unwrapped.lib
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
    tester $out/lib/x86_64-linux-gnu
    test -d $out/lib && chmod +x $out/lib/*

    runHook postInstall
  '';
}
