{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "ofed-scripts";
  version = "5.8-OFED.5.8.1.0.1";

  src = ../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
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
      test -d "$1" && (cp -r "$1"/* "$1"/.. && rm -r "$1") || (return 0)
    }

    tester $out/usr
    tester $out/lib/x86_64-linux-gnu
    find $out \( -name '*.so' -o -name '*.so.*' \) -exec chmod +x {} \;

    runHook postInstall
  '';
}
