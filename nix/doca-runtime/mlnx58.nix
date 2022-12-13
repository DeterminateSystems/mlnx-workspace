{ stdenv
, src'
, fetchzip
, kernel
, pkgs
}:
  let
  s = fetchzip {
    url = "mirror://kernel/linux/kernel/v5.x/linux-5.8.18.tar.xz";
    hash = "sha256-jnu9O49lO7bCkdq8tN34kK61pW0dEq8JVsOUv9ee1Ug=";
  };
  in
stdenv.mkDerivation {
  name = "mlnx-5.8";

  src = src' + "/src/mlnx-ofed-kernel-5.8";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ] ++ kernel.moduleBuildDependencies;

  buildInputs = [ kernel ];

  preConfigure = ''
  # configurePhase = '''
    mkdir ./kernel-5.8.18
    cp -r ${s}/* ./kernel-5.8.18
    ln -s ${kernel.configfile} ./kernel-5.8.18/.config
    export KSRC=$PWD/kernel-5.8.18
    # export KBUILD_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
    sed -E '/\/nix\/store/! s@/bin/@@' -i ./configure -i ./makefile
    # ./configure --kernel-version=5.8.18 --kernel-sources=${s} --with-njobs=$NIX_BUILD_CORES
  '';
} 
