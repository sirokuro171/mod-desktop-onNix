{
  description = "mod-audio for nix system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      mod-desktop = nixpkgs.legacyPackages.x86_64-linux.callPackage ./mod-desktop.nix { };
    in
    {
      packages."x86_64-linux".default = mod-desktop;
      packages."x86_64-linux"."mod-desktop" = mod-desktop;
    };
}
