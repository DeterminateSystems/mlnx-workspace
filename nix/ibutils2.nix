{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "ibutils2";
  version = "2.1.1-0.156.MLNX20221016.g4aceb16.58101";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.libibverbs
      self.libibumad

      # NOTE: this is actually from nixpkgs proper
      gcc-unwrapped.lib
      perl
      python3
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    # These perl files bury their shebang to like the 35th line, so the auto
    # patchshebang hook doesn't find it. Manually add it.
    sed -i '1i#!/usr/bin/perl -w' src/usr/bin/*.pl

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
    patchShebangs $out/bin/*.pl $out/bin/*.py

    runHook postInstall
  '';
}
