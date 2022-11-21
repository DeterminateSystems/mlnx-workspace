{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, config ? { }
}:
let
  kernelPackages = config.boot.kernelPackages or
    (lib.warn "config attrset needs to contain config.boot.kernelPackages to build kernel_mft_dkms"
      ({ callPackage = _: _: { }; })
    );

  scope = lib.makeScope pkgs.newScope (self: rec {
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
    };

    # doca-runtime meta package
    doca-runtime = {
      mlnx_dpdk = self.callPackage ./mlnx_dpdk.nix { }; # done
      rdma_core = self.callPackage ./rdma_core.nix { };
      ibacm = self.callPackage ./ibacm.nix { };
      mlnx_ofed_kernel_dkms = self.callPackage ./mlnx_ofed_kernel_dkms.nix { };
      iser_dkms = self.callPackage ./iser_dkms.nix { };
      knem_dkms = self.callPackage ./knem_dkms.nix { };
      libibumad = self.callPackage ./libibumad.nix { }; # done
      openvswitch_switch = self.callPackage ./openvswitch_switch.nix { };
      ucx = self.callPackage ./ucx.nix { }; # done
      srp_dkms = self.callPackage ./srp_dkms.nix { };
      libvma = self.callPackage ./libvma.nix { };
      librdmacm1 = self.callPackage ./librdmacm1.nix { };
      mlnx_ethtool = self.callPackage ./mlnx_ethtool.nix { };
      libopensm = self.callPackage ./libopensm.nix { }; # done
      knem = self.callPackage ./knem.nix { };
      isert_dkms = self.callPackage ./isert_dkms.nix { };
      mlnx_iproute2 = self.callPackage ./mlnx_iproute2.nix { };
      doca_prime_runtime = doca-tools.doca_prime_runtime;
      doca_grpc = self.callPackage ./doca_grpc.nix { };
      python3_protobuf = self.callPackage ./python3_protobuf.nix { };
      python3_grpcio = self.callPackage ./python3_grpcio.nix { };
      collectx = self.callPackage ./collectx.nix { }; # done
      mlnx_nvme_dkms = self.callPackage ./mlnx_nvme_dkms.nix { };
      flexio = self.callPackage ./flexio.nix { };
    };

    inherit (doca-tools)
      rxp_compiler
      ;

    inherit (doca-runtime)
      mlnx_dpdk
      libibumad
      ucx
      libopensm
      collectx
      ;

    # deps not part of a metapackage (that I've gotten to)
    libibnetdisc = self.callPackage ./libibnetdisc.nix { }; # done
    libibmad = self.callPackage ./libibmad.nix { }; # done
    librdmacm = self.callPackage ./librdmacm.nix { }; # done
    libibverbs = self.callPackage ./libibverbs.nix { }; # done
    doca_libs = self.callPackage ./doca_libs.nix { }; # done
    json_c = self.callPackage ./json_c.nix { }; # done
    hcoll = self.callPackage ./hcoll.nix { }; # done
    sharp = self.callPackage ./sharp.nix { }; # done

    # TODO: rather than refer to packages, move stuff like gcc-unwrapped here
    # (so it's accessible through `self`)

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
