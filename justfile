setup_source_ref:
  echo {{justfile_directory()}} > .source

apply: setup_source_ref
   nix run github:nix-community/home-manager -- switch --flake .

apply-static: setup_source_ref
  NP_RUNTIME=bwrap nix-portable nix run github:nix-community/home-manager -- switch --flake .
