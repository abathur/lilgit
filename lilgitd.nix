{ lib
, stdenv
, craneLib
, git
, openssl
, libiconv
, pkg-config
, darwin
}:

craneLib.buildPackage {
  pname = "lilgitd";
  version = "unset";

  src = craneLib.cleanCargoSource ./.;

  /* Jan 13 2022:
  Converting from crate2nix to crane and using only the minimum
  number of deps to build. Refer back to a21aaa6 for Cargo.nix +
  lilgitd.nix if there's a behavior slip somewhere.
  */
  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    libiconv
    darwin.Security
  ];

  nativeBuildInputs = [ pkg-config ];

  postPatch = ''
    substituteInPlace lilgitd.rs \
      --replace 'Command::new("git")' 'Command::new("${git}/bin/git")'
  '';
}
