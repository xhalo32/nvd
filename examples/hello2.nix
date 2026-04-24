let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
  }) { };
in
{
  stdenv = pkgs.stdenv; # expose stdenv for convenience
  package = pkgs.hello; # version 2.12.2
}
