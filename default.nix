{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) lib nix-gitignore python3 stdenv;
in
stdenv.mkDerivation {
  pname = "nvd";
  version = "0.2.0";

  src = nix-gitignore.gitignoreSourcePure [ ./.gitignore ] ./src;

  buildInputs = [ python3 ];

  buildPhase = ''
    runHook preBuild
    gzip nvd.1
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -m555 -Dt $out/bin nvd
    install -m444 -Dt $out/share/man/man1 nvd.1.gz
    runHook postInstall
  '';

  meta = {
    description = "Nix/NixOS package version diff tool";
    homepage = "https://gitlab.com/khumba/nvd";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.khumba ];
    platforms = lib.platforms.all;
  };
}
