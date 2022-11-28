{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "sharp";
  version = "3.1.0.MLNX20221025.ec223d82-1.58101";

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
      self.libibumad
      self.ucx

      # NOTE: this is actually from nixpkgs proper
      gcc-unwrapped.lib
      rdma-core
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    rsync -a ./src/opt/mellanox/sharp/ ./src
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
