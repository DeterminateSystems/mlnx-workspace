{ pkgs
, stdenv
, self
}:
stdenv.mkDerivation rec {
  pname = "mlnx-ofed-kernel-dkms";
  version = "5.8-OFED.5.8.1.0.1.1";

  src = ../../nv + "/${pname}_${version}_all.deb";

  nativeBuildInputs = with pkgs;
    [
      autoPatchelfHook
      dpkg
      rsync
    ];

  buildInputs = with pkgs;
    [
      # NOTE: this is actually from nixpkgs proper
      # openssl_1_1
      # zlib
      # gcc-unwrapped.lib
      # curl
    ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src ./src
    # opt=/opt/mellanox/collectx
    # rsync -a ./src/"$opt"/ ./src
    # rm -rf ./src/opt

    # for f in $(grep -rl "$opt"); do
    #   sed -i "s@$opt@${placeholder "out"}@g" "$f"
    # done

    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv src/* $out

    tester() {
      dir="$1"
      test -d "$1" && (cp -r "$1"/* "$1"/.. && rm -r "$1") || (return 0)
    }

    tester $out/usr
    tester $out/lib/x86_64-linux-gnu
    find $out \( -name '*.so' -o -name '*.so.*' \) -exec chmod +x {} \;

    runHook postInstall
  '';
}
