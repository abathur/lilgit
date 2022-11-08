{ lib
, resholve
, callPackage
, git
, coreutils
}:

let
  lilgitd = callPackage ./lilgitd.nix { };
in
resholve.mkDerivation rec {
  version = "unset";
  pname = "lilgit";
  src = lib.cleanSource ./.;
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

  passthru.tests = callPackage ./test.nix { };

  meta = with lib; {
    description = "A smol (quick) git status prompt plugin";
    homepage = https://github.com/abathur/lilgit;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
