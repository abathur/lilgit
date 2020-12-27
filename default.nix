#with import <n> {};
{ lib, stdenv, resholve, fetchFromGitHub, doCheck ? true, shellcheck, bashInteractive, git, python3 }:
let
  # src = lib.cleanSource ../../../../work/lilgit;
  src = fetchFromGitHub {
    owner = "abathur";
    repo = "lilgit";
    rev = "30d7ba3d3bf859d77606847861d0552725174f76";
    # rev = "v${version}";
    hash = "sha256-ykcNaEzcNZcMvspuRjJpJv8pbSVokQiaxGAbGU2Tqe0=";
  };
  lilgitd = python3.pkgs.buildPythonPackage {
    name = "lilgitd";
    inherit src;
    doCheck = false;
    buildInputs = [];
    propagatedBuildInputs = [ git python3.pkgs.pygit2 ];
  };
in
resholve.resholvePackage rec {
  version = "unset";
  pname = "lilgit";
  inherit src;
  solutions = {
    plugin = {
      scripts = [ "bin/lilgit.bash" ];
      inputs = [ lilgitd ];
      interpreter = "none";
    };
  };
  installPhase = ''
    mkdir -p $out/bin
    install lilgit.bash $out/bin/lilgit.bash
  '';

  inherit doCheck;
  doInstallCheck = doCheck;
  installCheckPhase = with stdenv.lib; ''
    ${shellcheck}/bin/shellcheck $out/bin/lilgit.bash
    # env to avoid python path problems
    # https://github.com/NixOS/nixpkgs/pull/102613 may fix
    env -i ${bashInteractive}/bin/bash -c "source $out/bin/lilgit.bash"
  '';

  meta = with stdenv.lib; {
    description = "A smol (quick) git status plugin";
    homepage = https://github.com/abathur/lilgit;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
