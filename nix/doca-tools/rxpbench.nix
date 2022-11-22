{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "rxpbench";
  version = "22.10.0";

  src = ../../nv + "/${pname}_${version}_amd64.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
    ];

  buildInputs = with pkgs;
    [
      self.libibverbs
      self.json_c
      self.libpcap
      self.rxp_compiler

      # NOTE: this is actually from nixpkgs proper
      gcc-unwrapped.lib
      rdma-core
      libbsd
      numactl
      jansson
      elfutils
      hyperscan
      python2
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv src/* $out

    tester() {
      dir="$1"
      test -d "$1" && (cp -r "$1"/* "$1"/.. && rm -r "$1") || (return 0)
    }

    tester $out/usr

    runHook postInstall
  '';
}

