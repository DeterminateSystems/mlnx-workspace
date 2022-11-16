# mlnx-workspace

https://www.notion.so/detsys/Mellanox-BlueField-35238edc01f041c89f3b5cd20e812b56

`nv/` dir is from https://linux.mellanox.com/public/repo/doca/latest/ubuntu20.04/amd64/

```
nix run nixpkgs#wget -- --no-parent --cut-dirs=6 -r https://linux.mellanox.com/public/repo/doca/latest/ubuntu20.04/amd64/
mv linux.mellanox.com nv
```
