let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;

  scope = lib.makeScope pkgs.newScope (self: {
    inherit self;

    # doca-tools meta package
    doca-tools = {
      infiniband_diags = self.callPackage ./infiniband_diags.nix { }; # done
      rdmacm_utils = self.callPackage ./rdmacm_utils.nix { };
      perftest = self.callPackage ./perftest.nix { };
      opensm = self.callPackage ./opensm.nix { };
      libvma_utils = self.callPackage ./libvma_utils.nix { };
      ibverbs_utils = self.callPackage ./ibverbs_utils.nix { };
      ibutils2 = self.callPackage ./ibutils2.nix { };
      rshim = self.callPackage ./rshim.nix { };
      doca_prime_tools = self.callPackage ./doca_prime_tools.nix { };
      rxpbench = self.callPackage ./rxpbench.nix { };
      rxp_compiler = self.callPackage ./rxp_compiler.nix { };
      kernel_mft_dkms = self.callPackage ./kernel_mft_dkms.nix { # done
        # TODO: we'll probably want to restrict this, OR use some helper
        # function from nixpkgs to create a module for all kernels
        kernel = pkgs.linux;
      };
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
  });
in
scope
  // scope.doca-tools
