{ self
, pkgs
, kernelPackages
, doca-tools
, linux, linux_latest
}:
rec {
  mlnx_dpdk = self.callPackage ./mlnx_dpdk.nix { }; # done
  rdma_core = self.callPackage ./rdma_core.nix { }; # done
  ibacm = self.callPackage ./ibacm.nix { }; # done
  mlnx_ofed_kernel_dkms = self.callPackage ./mlnx58.nix { inherit mlnx_ofed_kernel_dkms_src; kernel = kernel_5_8; }; # problematic
  mlnx_ofed_kernel_dkms_src = self.callPackage ./mlnx58src.nix { }; # problematic (not really, but part of it)
  iser_dkms = self.callPackage ./iser_dkms.nix { kernel = kernel_5_8; }; # problematic
  # iser_dkms = kernelPackages.callPackage ./iser_dkms.nix { };
  knem_dkms = kernelPackages.callPackage ./knem_dkms.nix { }; # done
  libibumad = self.callPackage ./libibumad.nix { }; # done
  openvswitch_switch = self.callPackage ./openvswitch_switch.nix { }; # done
  ucx = self.callPackage ./ucx.nix { }; # done
  srp_dkms = kernelPackages.callPackage ./srp_dkms.nix { }; # problematic
  libvma = self.callPackage ./libvma.nix { }; # done
  librdmacm1 = doca-tools.librdmacm; # done
  mlnx_ethtool = self.callPackage ./mlnx_ethtool.nix { }; # done
  libopensm = self.callPackage ./libopensm.nix { }; # done
  knem = self.callPackage ./knem.nix { }; # done
  isert_dkms = kernelPackages.callPackage ./isert_dkms.nix { }; # problematic
  mlnx_iproute2 = self.callPackage ./mlnx_iproute2.nix { }; # done
  doca_prime_runtime = doca-tools.doca_prime_runtime; # done
  doca_grpc = self.callPackage ./doca_grpc.nix { }; # done
  # python3_protobuf = self.callPackage ./python3_protobuf.nix { };
  # python3_grpcio = self.callPackage ./python3_grpcio.nix { };
  collectx = self.callPackage ./collectx.nix { }; # done
  # mlnx_nvme_dkms = kernelPackages.callPackage ./mlnx_nvme_dkms.nix { };
  flexio = self.callPackage ./flexio.nix { }; # done

  kernel_5_8 = self.callPackage ./58.nix { };
}
