{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "libvma-utils";
  version = "9.7.0-1";

  src = ../../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      # NOTE: this is actually from nixpkgs proper
      gcc-unwrapped.lib
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

    runHook postInstall
  '';
}
