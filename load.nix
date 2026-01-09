pkgs:
let
  packages =
    let
      dirs = pkgs.lib.filterAttrs (
        n: v: v == "directory" && builtins.pathExists (./pkgs + "/${n}/default.nix")
      ) (builtins.readDir ./pkgs);
    in
    pkgs.lib.mapAttrs (n: v: ./pkgs + "/${n}/default.nix") dirs;
in
pkgs.lib.mapAttrs (n: v: pkgs.callPackage v { }) packages
