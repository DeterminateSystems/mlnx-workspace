{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, config ? { }
}:
let
  kernelPackages = config.boot.kernelPackages
    or (throw "config attrset needs to contain config.boot.kernelPackages");

  scope = lib.makeScope pkgs.newScope (self: {
    inherit self;

    # doca-tools meta package
    doca-tools = {
      # TODO: go back and validate that all these packages don't have e.g.
      # python and perl binaries (since those don't get their shebangs patched
      # for whatever reason; at least, that's what happened in ibutils2)
      infiniband_diags = self.callPackage ./infiniband_diags.nix { }; # done
      rdmacm_utils = self.callPackage ./rdmacm_utils.nix { }; # done
      perftest = self.callPackage ./perftest.nix { }; # done
      opensm = self.callPackage ./opensm.nix { }; # done
      libvma_utils = self.callPackage ./libvma_utils.nix { }; # done
      ibverbs_utils = self.callPackage ./ibverbs_utils.nix { }; # done
      ibutils2 = self.callPackage ./ibutils2.nix { }; # done
      rshim = self.callPackage ./rshim.nix { };
      doca_prime_tools = self.callPackage ./doca_prime_tools.nix { };
      rxpbench = self.callPackage ./rxpbench.nix { };
      rxp_compiler = self.callPackage ./rxp_compiler.nix { };
      kernel_mft_dkms = kernelPackages.callPackage ./kernel_mft_dkms.nix { }; # done
      mft = self.callPackage ./mft.nix { };
      bfb2image = self.callPackage ./bfb2image.nix { };
      meson = self.callPackage ./meson.nix { };
      openmpi = self.callPackage ./openmpi.nix { };
      mpitests = self.callPackage ./mpitests.nix { };
      doca_remote_memory_app = self.callPackage ./doca_remote_memory_app.nix { };
      ofed_scripts = self.callPackage ./ofed_scripts.nix { };
    };

    # deps not part of a metapackage (that I've gotten to)
    libibnetdisc = self.callPackage ./libibnetdisc.nix { }; # done
    libibmad = self.callPackage ./libibmad.nix { }; # done
    libibumad = self.callPackage ./libibumad.nix { }; # done
    librdmacm = self.callPackage ./librdmacm.nix { }; # done
    libibverbs = self.callPackage ./libibverbs.nix { }; # done
    libopensm = self.callPackage ./libopensm.nix { }; # done
  });
in
scope
  // scope.doca-tools
