{ pkgs ? import <nixpkgs> { } }:

with pkgs;
bats.overrideAttrs ( old: rec {
    version = "1.2.1";
    src = fetchzip {
      url = "https://github.com/bats-core/bats-core/archive/v${version}.tar.gz";
      hash = "sha256-grB/rJaDU0fuw4Hm3/9nI2px8KZnSWqRjTJPd7Mmb7s=";
    };
    patchPhase = ''
      patchShebangs ./install.sh
    '';
    # bats-format-pretty
})
