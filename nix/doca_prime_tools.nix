{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "doca-prime-tools";
  version = "1.5.0055-1";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.doca_libs
      self.json_c

      # NOTE: this is actually from nixpkgs proper
      openssl_1_1
      gcc-unwrapped.lib
      zlib
      glib
      libbsd
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
      test -d "$1" && (mv "$1"/* "$1"/.. && rmdir "$1") || (return 0)
    }

    tester $out/usr

    runHook postInstall
  '';
}
