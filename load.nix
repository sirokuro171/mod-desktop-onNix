pkgs:
let
  # default.nixを探索
  defaults =
    let
      dirs = pkgs.lib.filterAttrs (
        n: v: v == "directory" && builtins.pathExists (./pkgs + "/${n}/default.nix")
      ) (builtins.readDir ./pkgs);
    in
    builtins.mapAttrs (n: v: ./pkgs + "/${n}/default.nix") dirs;

  loader =
    key: value:
    let
      loaded = import value;

      ## attrを読み込む
      attr_loader =
        n: v:
        if builtins.isFunction v then
          pkgs.callPackage v {}
        else if builtins.isAttrs v then
          ## 再帰的に読み込み、nullを除外
          pkgs.lib.filterAttrs (n: v: v != null) (builtins.mapAttrs attr_loader v)
        else
          null;
    in
    if builtins.isFunction loaded then
      { "${key}" = pkgs.callPackage loaded {}; }
    else if builtins.isAttrs loaded then
      builtins.mapAttrs attr_loader loaded
    else
      null;

  # default.nixをimport
  result = pkgs.lib.attrsets.mapAttrsToList loader defaults;

  # attrのみを抽出
  filtered = builtins.filter (e: builtins.isAttrs e) result;

  #   packages =
  #     let
  #       dirs = pkgs.lib.filterAttrs (
  #         n: v: v == "directory" && builtins.pathExists (./pkgs + "/${n}/default.nix")
  #       ) (builtins.readDir ./pkgs);
  #       default_list = pkgs.lib.mapAttrs (n: v: ./pkgs + "/${n}/default.nix") dirs;
  #     in
  #     pkgs.lib.mapAttrs (n: v: pkgs.callPackage v { });
in
pkgs.lib.attrsets.mergeAttrsList filtered
