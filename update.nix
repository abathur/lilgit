{ mkShell
, rustc
, cargo
, openssl
, libgit2
, cmake
, pkg-config
}:

mkShell {
  buildInputs = [ rustc cargo openssl openssl.dev libgit2 cmake pkg-config ];

  shellHook = ''
    cargo update
  '';
}
