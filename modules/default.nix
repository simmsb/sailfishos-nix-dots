{ ... }:

{
  disabledModules = [ "systemd.nix" ];
  imports = [
    ./mkAbsoluteSymlink.nix
    ./systemd.nix
  ];
}
