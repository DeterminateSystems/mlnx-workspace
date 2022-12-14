{ lib, fetchpatch, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with lib;

(buildLinux (args // rec {
  version = "5.8.18";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = if (modDirVersionArg == null) then concatStringsSep "." (take 3 (splitVersion "${version}.0")) else modDirVersionArg;

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  # If iterating on this kernel in some way, this makes the build much faster
  #ignoreConfigErrors = true;
  #autoModules = false;
  #structuredExtraConfig = with lib.kernel; lib.mapAttrs (n: v: lib.mkForce v) {
  #  XEN = yes;
  #  DRM = no;
  #  MLX4_EN = module;
  #  MLX5_CORE = module;
  #  MLXSW_CORE = module;
  #  MLXFW = module;
  #  MLX4_INFINIBAND = module;
  #  MLX5_INFINIBAND = module;
  #  MLX_PLATFORM = module;
  #};

  kernelPatches = [
    {
      name = "fix-with-newer-bintools";
      patch = (fetchpatch {
        name = "fix-with-newer-bintools";
        url = "https://github.com/torvalds/linux/commit/1d489151e9f9d1647110277ff77282fe4d96d09b.patch";
        sha256 = "sha256-qIYLuf9K/FFYxRQT2e/QNhRSZNNyStT/ItPnCgo2RY0=";
      });
    }
  ];

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "0d2mm16mjyl2d734ak0lj8vd76h3r0san7l7g2zczd5pjkva7d2a";
  };
}))
