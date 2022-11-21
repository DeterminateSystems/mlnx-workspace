{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "mft";
  version = "4.22.0-96";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      # NOTE: this is actually from nixpkgs proper
      gcc-unwrapped.lib
      zlib
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
      test -d "$1" && (cp -r "$1"/* "$1"/.. && rm -r "$1") || (return 0)
    }

    tester $out/usr
    rm $out/bin/mst # symlink to /etc/init.d/mst, which we don't have
    rm $out/bin/mft_uninstall.sh # uh yeah

    runHook postInstall
  '';
}
