let
  pkgs = import <nixpkgs> { };
in
rec {
  mod-desktop = pkgs.callPackage ./mod-desktop.nix { };
}
