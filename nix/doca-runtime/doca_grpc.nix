{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "doca-grpc";
  version = "1.5.0055-1";

  src = ../../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
      rsync
    ];

  buildInputs = with pkgs;
    [
      self.mlnx_dpdk
      self.json_c
      self.doca_libs

      # NOTE: this is actually from nixpkgs proper
      libbsd
      zlib
      gcc-unwrapped.lib
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    rsync -a ./src/opt/mellanox/doca/ ./src
    # for some godforsaken reason, they actually have non-FHS directories here
    # (./applications/application_recognition, and ./infrastructure/doca_grpc)
    # TODO: deal with that somehow
    rm -rf ./src/opt

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
