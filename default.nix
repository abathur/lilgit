{ pkgs ? import <nixpkgs> { }, doInstallCheck ? true }:

with pkgs;
# { lib, resholvePackage, fetchFromGitHub, doCheck ? true, doInstallCheck ? true, shellcheck, bashInteractive, git, python3 }:
let
  src = lib.cleanSource ./.;
  # src = fetchFromGitHub {
  #   owner = "abathur";
  #   repo = "lilgit";
  #   rev = "30d7ba3d3bf859d77606847861d0552725174f76";
  #   # rev = "v${version}";
  #   hash = "sha256-ykcNaEzcNZcMvspuRjJpJv8pbSVokQiaxGAbGU2Tqe0=";
  # };
  # TODO: temporary until bats update PR can be merged
  bats121 = callPackage ./bats.nix { };
  lilgitd = python3.pkgs.buildPythonApplication {
    name = "lilgitd";
    inherit src;
    doCheck = false;
    buildInputs = [];
    propagatedBuildInputs = [ git python3.pkgs.pygit2 ];
  };
in
resholvePackage rec {
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

  installPhase = ''
    install -Dv lilgit.bash $out/bin/lilgit.bash
  '';

  installCheckInputs = [ bashInteractive git shellcheck bats121 ];
  inherit doInstallCheck;
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  installCheckPhase = ''
    export LILGIT=$out/bin/lilgit.bash
    ${shellcheck}/bin/shellcheck $out/bin/lilgit.bash
    cat tests/head.bats tests/repo.bash > tests/ephemeral.bats
    bats tests/ephemeral.bats
  '';

  meta = with lib; {
    description = "A smol (quick) git status plugin";
    homepage = https://github.com/abathur/lilgit;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
