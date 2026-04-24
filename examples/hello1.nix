let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/3e2cf88148e732abc1d259286123e06a9d8c964a.tar.gz";
  }) { };
in
{
  inherit pkgs;
  stdenv = pkgs.stdenv; # expose stdenv for convenience
  package = pkgs.hello; # version 2.12.1
}
