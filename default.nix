{ pkgs ? import <nixpkgs> { }, doCheck ? true, doInstallCheck ? true }:

with pkgs;
# TODO: below may be outdated per riir
# { lib, resholve, fetchFromGitHub, doCheck ? true, doInstallCheck ? true, shellcheck, bashInteractive, git }:
let
  src = lib.cleanSource ./.;
  # src = fetchFromGitHub {
  #   owner = "abathur";
  #   repo = "lilgit";
  #   rev = "0924de1e75810ca1799b09a17aa0d5290428087b";
  #   # rev = "v${version}";
  #   hash = "sha256-+EN7KuNgS7FOrdSEx9jPb9aYtXPHi4ACMRWN7GE7BjM=";
  # };
  lilgitd = callPackage ./lilgitd.nix { };
in
resholve.mkDerivation rec {
  version = "unset";
  pname = "lilgit";
  inherit src;
  solutions = {
    plugin = {
      scripts = [ "bin/lilgit.bash" ];
      inputs = [ lilgitd git coreutils ];
      interpreter = "none";
    };
  };

  inherit doCheck;
  checkInputs = [ rustfmt shellcheck ];
  checkPhase = ''
    ${shellcheck}/bin/shellcheck lilgit.bash
    ${rustfmt}/bin/rustfmt lilgitd.rs --check
  '';

  installPhase = ''
    install -Dv lilgit.bash $out/bin/lilgit.bash
  '';

  passthru.tests.upstream = lilgit.unresholved.overrideAttrs (old: {
        name = "${old.name}-tests";
        dontInstall = true; # just need the build directory
        inherit doInstallCheck;
        installCheckInputs = [ bashInteractive git bats ];
        installCheckPhase = ''
          export LILGIT=$out/bin/lilgit.bash
          cat tests/head.bats tests/repo.bash > tests/ephemeral.bats
          bats tests/ephemeral.bats
        '';
      });

  meta = with lib; {
    description = "A smol (quick) git status prompt plugin";
    homepage = https://github.com/abathur/lilgit;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
