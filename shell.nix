{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  lilgit = callPackage ./default.nix { doInstallCheck=false; };
  demo = ./prompt_demo.sh;
in
pkgs.mkShell {
  buildInputs = [ lilgit bashInteractive_5 ];
  shellHook = ''
    exec /usr/bin/env -i LILGITBASH="${lilgit}/bin/lilgit.bash" ${bashInteractive_5}/bin/bash --rcfile ${demo} --noprofile -i
  '';
}
