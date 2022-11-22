{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "collectx";
  version = "1.11.0-6225698";

  src = ../../nv + "/${pname}_${version}-ubuntu20.04-x86_64-clxapi.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      # NOTE: this is actually from nixpkgs proper
      openssl_1_1
      zlib
      gcc-unwrapped.lib
      curl
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    mv ./src/opt/mellanox/collectx/* ./src
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
