{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "doca-libs";
  version = "1.5.0055-1";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
      rsync
    ];

  buildInputs = with pkgs;
    [
      self.libibverbs
      self.json_c
      self.collectx
      self.rxp_compiler
      self.mlnx_dpdk

      # NOTE: this is actually from nixpkgs proper
      openssl_1_1
      gcc-unwrapped.lib
      rdma-core
      libbsd
      glib
      libnghttp2
      libzip
      uriparser
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    opt=/opt/mellanox/doca
    rsync -a ./src/"$opt"/ ./src
    rm -rf ./src/opt

    for f in $(grep -rl "$opt"); do
      sed -i "s@$opt@${placeholder "out"}@g" "$f"
    done

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
    tester $out/lib/x86_64-linux-gnu
    find $out \( -name '*.so' -o -name '*.so.*' \) -exec chmod +x {} \;

    runHook postInstall
  '';
}
