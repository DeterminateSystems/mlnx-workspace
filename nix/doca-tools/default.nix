{ self
, kernelPackages
, pkgs
}:
{
  infiniband_diags = self.callPackage ./infiniband_diags.nix { }; # done
  rdmacm_utils = self.callPackage ./rdmacm_utils.nix { }; # done
  perftest = self.callPackage ./perftest.nix { }; # done
  opensm = self.callPackage ./opensm.nix { }; # done
  libvma_utils = self.callPackage ./libvma_utils.nix { }; # done
  ibverbs_utils = self.callPackage ./ibverbs_utils.nix { }; # done
  ibutils2 = self.callPackage ./ibutils2.nix { }; # done
  rshim = self.callPackage ./rshim.nix { }; # done
  doca_prime_tools = self.callPackage ./doca_prime_tools.nix { }; # done
  rxpbench = self.callPackage ./rxpbench.nix { }; # done
  rxp_compiler = self.callPackage ./rxp_compiler.nix { }; # done
  kernel_mft_dkms = kernelPackages.callPackage ./kernel_mft_dkms.nix { }; # done
  mft = self.callPackage ./mft.nix { }; # done
  bfb2image = self.callPackage ./bfb2image.nix { }; # done
  # meson = self.callPackage ./meson.nix { };
  openmpi = self.callPackage ./openmpi.nix { }; # done
  mpitests = self.callPackage ./mpitests.nix { }; # done
  doca_remote_memory_app = self.callPackage ./doca_remote_memory_app.nix { }; # done
  ofed_scripts = self.callPackage ./ofed_scripts.nix { }; # done
}
