{ callPackage, lib, git, openssl, libiconv, zlib, libssh2, pkg-config, buildRustCrate, defaultCrateOverrides }:
# let
#   ever-given = callPackage (builtins.fetchTarball "https://github.com/nix-community/ever-given/archive/f9bead48ed0d53dc47a079607390dbe14ae5745e.tar.gz") {};
# in ever-given.buildRustPackage {
#   pname = "lilgitd";
#   version = "unset";
#   src = lib.cleanSource ./.;
# }
let
  lilgitd = (callPackage ./Cargo.nix {
    buildRustCrate = buildRustCrate.override {
      defaultCrateOverrides = defaultCrateOverrides // {
        lilgitd = attrs: {
          propagatedBuildInputs = [ git ];
          buildInputs = [ openssl libiconv ];
        };
        bitflags = attrs: {
          buildInputs = [ libiconv ];
        };
        libc = attrs: {
          buildInputs = [ libiconv ];
        };
        libssh2-sys = attrs: {
          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ openssl zlib libssh2 libiconv ];
        };
        libz-sys = attrs: {
          buildInputs = [ libiconv ];
        };
        log = attrs: {
          buildInputs = [ libiconv ];
        };
        openssl-sys = attrs: {
          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ libiconv openssl ];
        };
        proc-macro2 = attrs: {
          buildInputs = [ libiconv ];
        };
        syn = attrs: {
          buildInputs = [ libiconv ];
        };
        tokio = attrs: {
          buildInputs = [ libiconv ];
        };
        tokio-macros = attrs: {
          buildInputs = [ libiconv ];
        };
      };
    };
  });
in lilgitd.rootCrate.build
