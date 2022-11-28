{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "mpitests";
  version = "3.2.20-de56b6b.58101";

  src = ../../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
      rsync
    ];

  buildInputs = with pkgs;
    [
      self.doca-tools.openmpi
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    rsync -a ./src/usr/mpi/gcc/openmpi*/ ./src
    rm -rf ./src/usr

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
