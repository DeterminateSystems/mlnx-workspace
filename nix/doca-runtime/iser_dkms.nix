{ pkgs
, stdenv
, self
, kernel
}:
stdenv.mkDerivation rec {
  pname = "iser-dkms";
  version = "5.8-OFED.5.8.0.4.8.1";

  src = ../../nv + "/${pname}_${version}_all.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
      exa
    ] ++ kernel.moduleBuildDependencies;

  # FIXME: see if it loads in a vm test or something; this may be necessary
  # hardeningDisable = [ "pic" ];

  buildFlags = [
    # "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "K_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "K_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    # exa -T src
    pushd src/usr/src/iser-*
    # cat makefile
    sed -i '1i#include <linux/version.h>' iscsi_iser.c

    runHook postUnpack
  '';

buildPhase = '':'';

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

