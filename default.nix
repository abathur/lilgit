#with import <n> {};
{ lib, stdenv, fetchFromGitHub, doCheck ? true, shellcheck, bashInteractive, git, python3 }:
let
  src = lib.cleanSource ../../../../work/lilgit;
  # src = fetchFromGitHub {
  #   owner = "abathur";
  #   repo = "lilgit";
  #   rev = "b6753c6c17be8b021eedffd57a6918f80b914662";
  #   # rev = "v${version}";
  #   sha256 = "0jninx8aasa83g38qdpzy86m71xkpk7dzz8fvnab3lyk9fll4jk0";
  # };
  lilgitd = python3.pkgs.buildPythonPackage {
    name = "lilgitd";
    inherit src;
    doCheck = false;
    buildInputs = [];
    propagatedBuildInputs = [ python3.pkgs.pygit2 ];
  };
in
stdenv.mkDerivation rec {
  version = "unset";
  pname = "lilgit";
  inherit src;
  patchPhase = ''
    substituteInPlace lilgit.bash --replace lilgitd ${lilgitd}/bin/.lilgitd-wrapped
  '';
  installPhase = ''
    mkdir -p $out/bin
    install lilgit.bash $out/bin/lilgit.bash
  '';

  inherit doCheck;
  checkInputs = [ shellcheck bashInteractive ];
  doInstallCheck = doCheck;
  installCheckPhase = with stdenv.lib; ''
    shellcheck ./lilgit.bash
    ( source ./lilgit.bash )
  '';

  meta = with stdenv.lib; {
    description = "A smol (quick) git status plugin";
    homepage = https://github.com/abathur/lilgit;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
