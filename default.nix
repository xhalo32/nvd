{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "nvd";

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
}
