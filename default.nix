let
  pkgs = import <nixpkgs> { };
in
rec {
  mod-desktop = pkgs.callPackage ./pkgs/mod-desktop/default.nix { };
}
