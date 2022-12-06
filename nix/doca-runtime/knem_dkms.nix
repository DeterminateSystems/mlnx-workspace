{ pkgs
, stdenv
, self
, kernel
}:
stdenv.mkDerivation rec {
  pname = "knem-dkms";
  version = "1.1.4.90mlnx1-OFED.5.8.0.4.7.1";

  src = ../../nv + "/${pname}_${version}_all.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ] ++ kernel.moduleBuildDependencies;

  # FIXME: see if it loads in a vm test or something; this may be necessary
  # hardeningDisable = [ "pic" ];

  configureFlags = [
    "LINUX_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "LINUX_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    pushd src/usr/src/knem-*

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    for module in $(find -iname '*.ko'); do
      install -D "$module" $out/lib/modules/${kernel.modDirVersion}/extra/"$(basename "$module")"
    done

    popd
    mv src/* $out

    tester() {
      dir="$1"
      test -d "$1" && (cp -r "$1"/* "$1"/.. && rm -r "$1") || (return 0)
    }

    tester $out/usr

    runHook postInstall
  '';
}
