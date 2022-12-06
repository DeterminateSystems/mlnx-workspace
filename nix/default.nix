{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, config ? { }
}:
let
  kernelPackages = config.boot.kernelPackages or
    (lib.warn "config attrset needs to contain config.boot.kernelPackages to build *_dkms"
      ({ callPackage = _: _: { }; })
    );

  scope = lib.makeScope pkgs.newScope (self: rec {
    inherit self;

    # doca-tools meta package
    doca-tools = import ./doca-tools { inherit self kernelPackages; };

    # doca-runtime meta package
    doca-runtime = import ./doca-runtime { inherit self kernelPackages doca-tools; };

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
    dpcp = self.callPackage ./dpcp.nix { }; # done

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
