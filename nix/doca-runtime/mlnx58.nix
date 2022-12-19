{ stdenv
, buildLinux
, mlnx_ofed_kernel_dkms_src
, fetchzip
, kernel
, pkgs
, applyPatches
, rsync
, fetchpatch
, kmod
, pahole
, breakpointHook
}:
let
  lib = pkgs.lib // {
    elementsInDir = dir: lib.mapAttrsToList (name: type: { inherit type name; path = dir + "/${name}"; }) (builtins.readDir dir);
    filesInDir = dir: map ({ path, ... }: path) (pkgs.lib.filter (entry: entry.type == "regular") (lib.elementsInDir dir));
  };
in stdenv.mkDerivation rec {
  pname = "mlnx-ofed-modules";
  inherit (kernel) version;

  src = mlnx_ofed_kernel_dkms_src + "/src/mlnx-ofed-kernel-5.8";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    pahole
    breakpointHook
  ] ++ kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "INSTALL_PATH=${placeholder "out"}/lib/modules/${kernel.modDirVersion}"
  ];
  installFlags = kernel.installFlags ++ [
    "INSTALL_PATH=${placeholder "out"}/lib/modules/${kernel.modDirVersion}"
    "DEPMOD=${kmod}/bin/depmod"
  ];
  KSRC="${kernel.dev}/lib/modules/${kernel.modDirVersion}/source";
  KSRC_OBJ="${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/build";
  KLIB_BUILD="${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/build";

  configureFlags = [
    "--with-core-mod"
    "--with-user_mad-mod"
    "--with-user_access-mod"
    "--with-addr_trans-mod"
    "--with-mlx5-mod"
    "--with-mlxfw-mod"
    "--with-ipoib-mod"
    #"--with-nvmf_host-mod"
    #"--with-nvmf_target-mod"
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-njobs=$NIX_BUILD_CORES")
  '';

  postPatch = ''
    find . -type f -exec sed -E '/\/nix\/store/! s@/bin/@@' -i {} +
  '';
}
