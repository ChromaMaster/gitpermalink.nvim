{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              #Add here dependencies for the project.
              lua

              luajitPackages.luarocks # A package manager for Lua modules.
              luajitPackages.busted # Elegant Lua unit testing
              luajitPackages.luafilesystem
            ];
          };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
