{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    crane = {
      url = "github:ipetkov/crane/v0.13.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    bats-require = {
      url = "github:abathur/bats-require";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  description = "A smol (quick) git status prompt plugin";

  outputs = { self, nixpkgs, flake-utils, flake-compat, bats-require, crane }:
    {
      overlays.default = final: prev: {
        lilgit = prev.callPackage ./lilgit.nix { craneLib = crane.mkLib prev; };
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
        demo = ./prompt_demo.sh;
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
            default = pkgs.mkShell {
              buildInputs = [ pkgs.lilgit pkgs.bashInteractive ];
              shellHook = ''
                exec /usr/bin/env -i LILGITBASH="${pkgs.lilgit}/bin/lilgit.bash" ${pkgs.bashInteractive}/bin/bash --rcfile ${demo} --noprofile -i
              '';
            };
            update = pkgs.callPackage ./update.nix { };
          };
        }
    );
}
