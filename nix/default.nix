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
      rshim = self.callPackage ./rshim.nix { }; # done
      doca_prime_tools = self.callPackage ./doca_prime_tools.nix { }; # done
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
    doca_libs = self.callPackage ./doca_libs.nix { }; # done
    json_c = self.callPackage ./json_c.nix { }; # done
    collectx = self.callPackage ./collectx.nix { }; # done
    rxp_compiler = self.callPackage ./rxp_compiler.nix { }; # done
    mlnx_dpdk = self.callPackage ./mlnx_dpdk.nix { }; # done

    libpcap = (pkgs.libpcap.overrideAttrs ({ postInstall ? "", ... }: {
      # 0.8 was so many years ago we'd probably have to rebuild the entirety
      # of stdenv to get it. Supposedly, this is safe...
      # https://github.com/jclehner/nmrpflash/issues/27
      postInstall = postInstall + ''
        cd $out/lib
        ln -s libpcap.so.1 libpcap.so.0.8
      '';
    }));
  });
in
scope
  // scope.doca-tools
