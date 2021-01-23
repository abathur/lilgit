{ pkgs ? import <nixpkgs> { }, doInstallCheck ? true }:

with pkgs;
# TODO: below may be outdated per riir
# { lib, resholvePackage, fetchFromGitHub, doCheck ? true, doInstallCheck ? true, shellcheck, bashInteractive, git }:
let
  src = lib.cleanSource ./.;
  # src = fetchFromGitHub {
  #   owner = "abathur";
  #   repo = "lilgit";
  #   rev = "30d7ba3d3bf859d77606847861d0552725174f76";
  #   # rev = "v${version}";
  #   hash = "sha256-ykcNaEzcNZcMvspuRjJpJv8pbSVokQiaxGAbGU2Tqe0=";
  # };
  lilgitd = callPackage ./lilgitd.nix { };
in
resholvePackage rec {
  version = "unset";
  pname = "lilgit";
  inherit src;
  solutions = {
    plugin = {
      scripts = [ "bin/lilgit.bash" ];
      inputs = [ lilgitd git coreutils ]; # lilgitd
      interpreter = "none";
    };
  };

  installPhase = ''
    install -Dv lilgit.bash $out/bin/lilgit.bash
  '';

  installCheckInputs = [ bashInteractive git shellcheck bats ];
  inherit doInstallCheck;
  installCheckPhase = ''
    export LILGIT=$out/bin/lilgit.bash
    ${shellcheck}/bin/shellcheck $out/bin/lilgit.bash
    cat tests/head.bats tests/repo.bash > tests/ephemeral.bats
    bats tests/ephemeral.bats
    echo WAT?
  '';

  meta = with lib; {
    description = "A smol (quick) git status prompt plugin";
    homepage = https://github.com/abathur/lilgit;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
