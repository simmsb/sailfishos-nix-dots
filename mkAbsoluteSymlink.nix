{
  config,
  pkgs,
  lib,
  ...
}:

{
  config.lib.hm.mkDotfileSymlink =
    path:
    let
      repo_root = /. + builtins.readFile ./.source;
      relative = lib.path.removePrefix ../. path;
    in
    config.lib.file.mkOutOfStoreSymlink (lib.path.append repo_root relative);
}
