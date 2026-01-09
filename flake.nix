{
  description = "mod-audio for nix system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    # let
    #   mod-desktop = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/mod-desktop/default.nix { };
    # in
    {
      packages."x86_64-linux" = (import ./load.nix nixpkgs.legacyPackages.x86_64-linux);
    };
}
