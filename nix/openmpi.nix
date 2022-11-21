{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "openmpi";
  version = "4.1.5a1-1.58101";

  src = ../nv + "/${pname}_${version}_all.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.ucx
      self.hcoll

      # NOTE: this is actually from nixpkgs proper
      libnl
      udev
      zlib
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    mv ./src/usr/mpi/gcc/openmpi*/* ./src
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
