{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "perftest";
  version = "4.5-0.18.gfcddfe0.58101";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.librdmacm
      self.libibverbs
      self.libibumad

      # NOTE: this is actually from nixpkgs proper
      pciutils
      rdma-core # libmlx5.so.1; for whatever reason, the vendored debian
                # package doesn't include this dynamic object, so we
                # have to use the one from upstream, as packaged by
                # nixpkgs
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
