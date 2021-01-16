{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  nixpkgs = ../nixpkgs;
  our_lilgit = callPackage ./default.nix { };
  bats121 = bats.overrideAttrs ( old: rec {
    version = "1.2.1";
    src = fetchzip {
      url = "https://github.com/bats-core/bats-core/archive/v${version}.tar.gz";
      hash = "sha256-grB/rJaDU0fuw4Hm3/9nI2px8KZnSWqRjTJPd7Mmb7s=";
    };
    buildInputs = [ pkgs.bash_5 ];
    patchPhase = ''
      patchShebangs ./install.sh
    '';
  });
in
stdenv.mkDerivation {
  name = "lilgit-ci";
  src = builtins.filterSource
    (path: type:
      type != "directory" || baseNameOf path
      == "tests") ./.;

  doCheck = true;
  checkInputs = with pkgs; [ bash_5 gitAndTools.gitstatus git our_lilgit time bats121 unixtools.column ];

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
    RUNS=100 bats tests/ephemeral.bats
  '';
}
