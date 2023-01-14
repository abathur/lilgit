# Changelog

## unreleased (...)
- Test flake and traditional demos
- Update instructions for flake-based demo
- Update instructions for general flake usage

## v0.3.1 (Jan 13 2023)
- Update demo for flake

## v0.3.0 (Jan 13 2023)
- Convert to nix flake
- switch from crate2nix -> crane
- Update cargo deps

## v0.2.1 (May 28 2022)
- Track nixpkgs changes
- Move tests into separate build

## v0.2.0 (Dec 2 2021)
- Update dependencies

## v0.1.0 (Jul 8 2021)
- Work around an issue with dangling lilgitd processes left
  when you open/close or start/exit shells. This entails
  adding `__go_off_now_lilgit` to an EXIT trap in your shell
- Fix some libiconv issues caused by shifts upstream in nixpkgs.

## Jan 23 2021
Rewrote lilgitd in Rust (from Python).

## Jan 17 2021
Added a nix-shell based demo to try-before-you-buy.

## Jan 16 2021
Added tests/CI, and fixed some bugs flushed out by doing so:
- shelling out to git was using $PWD, so it was keeping whatever
  directory you started lilgitd from as its context. Now explictly
  passing a path.
- ferret out some conditions that could cause errors/exceptions

## Dec 26 2020
Ignore SIGINT to avoid dying on ctrl-c.

## Dec 25 2020
Initial publication.
