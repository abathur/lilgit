{ lib
, resholve
, callPackage
, git
, coreutils
, craneLib
}:

let
  lilgitd = callPackage ./lilgitd.nix { inherit craneLib; };
in
resholve.mkDerivation rec {
  version = "0.3.0";
  pname = "lilgit";
  src = lib.cleanSource ./.;
  solutions = {
    plugin = {
      scripts = [ "bin/lilgit.bash" ];
      inputs = [ lilgitd ];
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
