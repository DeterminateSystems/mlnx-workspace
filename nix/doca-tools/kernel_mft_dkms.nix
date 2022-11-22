{ pkgs
, stdenv
, self
, kernel
}:
stdenv.mkDerivation rec {
  pname = "kernel-mft-dkms";
  version = "4.22.0-96";

  src = ../../nv + "/${pname}_${version}_all.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
      tree
    ] ++ kernel.moduleBuildDependencies;

  # FIXME: see if it loads in a vm test or something; this may be necessary
  # hardeningDisable = [ "pic" ];

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    pushd src/usr/src/${pname}-*

    runHook postUnpack
  '';

  postPatch = ''
    substituteInPlace mst_backward_compatibility/mst_pciconf/Makefile \
      --replace '/lib/modules/$(KVERSION)/build' '$(KERNEL_DIR)' \
      --replace '$(PWD)/$(NNT_DRIVER_LOCATION)' "$(pwd)/nnt_driver"

    substituteInPlace mst_backward_compatibility/mst_pci/Makefile \
      --replace '/lib/modules/$(KVERSION)/build' '$(KERNEL_DIR)' \
      --replace '$(PWD)/$(NNT_DRIVER_LOCATION)' "$(pwd)/nnt_driver"

    substituteInPlace mst_backward_compatibility/mst_ppc/Makefile \
      --replace '/lib/modules/$(KVERSION)/build' '$(KERNEL_DIR)' \
      --replace '$(PWD)/$(NNT_DRIVER_LOCATION)' "$(pwd)/nnt_driver"

    substituteInPlace nnt_driver/Makefile \
      --replace '/lib/modules/$(KVERSION)/build' '$(KERNEL_DIR)'
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
