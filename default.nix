{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  },
}:
rec {
  package = pkgs.callPackage ./nvd.nix { };
  shell = pkgs.mkShellNoCC {
    inputsFrom = [ package ];
  };
}
