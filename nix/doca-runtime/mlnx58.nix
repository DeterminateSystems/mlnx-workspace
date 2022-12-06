{ stdenv
, src'
, fetchzip
, kernel
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

  preConfigure = ''
    mkdir ./kernel-5.8.18
    cp -r ${s} ./kernel-5.8.18
    ln -s ${kernel.configfile} ./kernel-5.8.18/.config
    export KSRC=$PWD/kernel-5.8.18
  '';
  LINUX_CONFIG = kernel.configfile;
} 
