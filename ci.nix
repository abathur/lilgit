{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  nixpkgs = ../nixpkgs;
  our_lilgit = (builtins.getFlake (toString ./.)).packages.${builtins.currentSystem}.default;
  # override for bash_5
  our_bats = bats.overrideAttrs ( old: rec {
    buildInputs = [ bash_5 ];
  });
in
stdenv.mkDerivation {
  name = "lilgit-ci";
  src = builtins.filterSource
    (path: type:
      type != "directory" || baseNameOf path
      == "tests") ./.;

  doCheck = true;
  checkInputs = with pkgs; [ bash_5 gitAndTools.gitstatus git our_lilgit time our_bats unixtools.column ];

  installPhase = ''
    column -s, -t $out/timings
  '';

  LILGIT="${our_lilgit}/bin/lilgit.bash";
  GITSTATUS="${gitAndTools.gitstatus}/share/gitstatus/gitstatus.plugin.sh";
  NIXPKGS="${nixpkgs}";

  checkPhase = ''
    git config features.manyFiles true
    mkdir $out
    patchShebangs .
    cat tests/head_nixpkgs.bats tests/repo.bash > tests/ephemeral.bats
    RUNS=1 bats tests/ephemeral.bats
    RUNS=10 bats tests/ephemeral.bats
    RUNS=100 bats tests/ephemeral.bats
  '';
}
