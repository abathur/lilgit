{ lilgit
, rustfmt
, shellcheck
, bashInteractive
, git
, bats
, bats-require
}:

{
  upstream = lilgit.unresholved.overrideAttrs (old: {
    name = "${old.pname}-tests";
    dontInstall = true; # just need the build directory
    doCheck = true;
    checkInputs = [ rustfmt shellcheck ];
    checkPhase = ''
      shellcheck lilgit.bash
      rustfmt lilgitd.rs --check
    '';
    doInstallCheck = true;
    installCheckInputs = [
      bashInteractive
      git
      bats
      # (bats.withLibraries (p: [ bats-require ]))
    ];
    # TODO: see if LILGIT env is moot now that this is its own drv
    installCheckPhase = ''
      export LILGIT=${lilgit}/bin/lilgit.bash
      cat tests/head.bats tests/repo.bash > tests/ephemeral.bats
      bats --verbose-run tests/ephemeral.bats
      touch $out
    '';
  });
}
