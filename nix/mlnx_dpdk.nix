{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "mlnx-dpdk";
  version = "20.11.0-6.1.5";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.libibverbs

      # NOTE: this is actually from nixpkgs proper
      rdma-core
      libbsd
      zlib
      numactl
      jansson
      elfutils
      (libpcap.overrideAttrs ({ postInstall ? "", ... }: {
        # 0.8 was so many years ago we'd probably have to rebuild the entirety
        # of stdenv to get it. Supposedly, this is safe...
        # https://github.com/jclehner/nmrpflash/issues/27
        postInstall = postInstall + ''
          cd $out/lib
          ln -s libpcap.so.1 libpcap.so.0.8
        '';
      }))
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    mv ./src/opt/mellanox/dpdk/lib ./src

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
