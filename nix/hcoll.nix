{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "hcoll";
  version = "4.8.3220-1.58101";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.libibverbs
      self.librdmacm
      self.ucx
      self.sharp
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    mv ./src/opt/mellanox/hcoll/* ./src
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
