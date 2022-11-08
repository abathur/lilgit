{
  inputs = {
    /*
    this pin dates to oct 22 2022; after that I start running
    into https://github.com/kolloch/crate2nix/issues/263; I don't
    grok rust or darwin builds well enough for it to be super obvs
    what's going on here...
    */
    nixpkgs.url = "github:nixos/nixpkgs/4f8287f3d597c73b0d706cfad028c2d51821f64d";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    bats-require = {
      url = "github:abathur/bats-require";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  # description = "Bash library for neighborly signal sharing";

  outputs = { self, nixpkgs, flake-utils, flake-compat, bats-require }:
    {
      overlays.default = final: prev: {
        lilgit = prev.callPackage ./lilgit.nix { };
      };
      # shell = ./shell.nix;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            bats-require.overlays.default
            self.overlays.default
          ];
        };
      in
        {
          packages = {
            inherit (pkgs) lilgit;
            default = pkgs.lilgit;
          };
          checks = pkgs.callPackages ./test.nix {
            inherit (pkgs) lilgit;
          };
          devShells = {
            default = pkgs.callPackage ./update.nix { };
          };
        }
    );
}
