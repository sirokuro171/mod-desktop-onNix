let
  pkgs = import <nixpkgs> { };
in
rec {
  mod-desktop = pkgs.callPackage ./pkgs/mod-desktop/default.nix { };
  waveform = pkgs.callPackage ./pkgs/waveform/default.nix { };
}
