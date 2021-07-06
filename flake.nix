{
  description = "nvd";
  inputs = {
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, flake-utils, nixpkgs, ... }: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      defaultApp = {
        type = "app";
        program = "${self.packages.${system}.nvd}/bin/nvd";
      };
      defaultPackage = self.packages.${system}.nvd;
      packages.nvd = pkgs.callPackage ./default.nix { };
    }
  ));
}
