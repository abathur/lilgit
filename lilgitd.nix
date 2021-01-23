{ callPackage, git, openssl, buildRustCrate, defaultCrateOverrides }:

let
  lilgitd = (callPackage ./Cargo.nix {
    buildRustCrate = buildRustCrate.override {
      defaultCrateOverrides = defaultCrateOverrides // {
        lilgitd = attrs: {
          propagatedBuildInputs = [ git ];
          buildInputs = [ openssl ];
        };
      };
    };
  });
in lilgitd.rootCrate.build
