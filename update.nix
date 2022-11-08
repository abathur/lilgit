{ mkShell
, rustc
, cargo
, crate2nix
, openssl
, libgit2
, cmake
, pkg-config
}:

mkShell {
  buildInputs = [ rustc cargo crate2nix openssl openssl.dev libgit2 cmake pkg-config ];
  # cargo build
  shellHook = ''
    cargo update
    crate2nix generate
  '';
}
