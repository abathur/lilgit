{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  nixpkgs = ../nixpkgs;
  our_lilgit = callPackage ./default.nix { };
in
stdenv.mkDerivation {
  name = "lilgit-ci";
  src = builtins.filterSource
    (path: type:
      type != "directory" || baseNameOf path
      == "tests") ./.;

  doCheck = true;
  checkInputs = with pkgs; [ bash_5 gitAndTools.gitstatus git our_lilgit time bats unixtools.column ];

  installPhase = ''
    column -s, -t $out/timings
  '';

  LILGIT="${our_lilgit}/bin/lilgit.bash";
  GITSTATUS="${gitAndTools.gitstatus}/gitstatus.plugin.sh";
  NIXPKGS="${nixpkgs}";
  # RSGITFSMON="${gitAndTools.rs-git-fsmonitor}/bin/rs-git-fsmonitor";

  checkPhase = ''
    mkdir $out
    patchShebangs .
    cat tests/head_nixpkgs.bats tests/repo.bash > tests/ephemeral.bats
    RUNS=1 bats tests/ephemeral.bats
    RUNS=10 bats tests/ephemeral.bats
    # TODO: I want 100 here, but there's some
    # flaky hang condition; lowering to increase
    # odds we can complete any given test run
    RUNS=20 bats tests/ephemeral.bats
  '';
}
