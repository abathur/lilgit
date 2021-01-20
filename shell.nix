{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  lilgit = callPackage ./default.nix { doInstallCheck=false; };
  demo = ./prompt_demo.sh;
in
pkgs.mkShell {
  buildInputs = [ lilgit bashInteractive ];
  shellHook = ''
    exec /usr/bin/env -i LILGITBASH="${lilgit}/bin/lilgit.bash" ${bashInteractive}/bin/bash --rcfile ${demo} --noprofile -i
  '';
}
