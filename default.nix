{ pkgs ? import <nixpkgs> {}
, silenceWarning ? false
}:
let
  inherit (pkgs) lib nix-gitignore python3 stdenv;

  warning =
    "This is a development build of nvd from git master.\n"
    + "On or around Oct 19, 2024, nvd will be moving to Sourcehut.\n"
    + "Please consider using the latest stable nvd release from nixpkgs,\n"
    + "but if you wish to continue pulling the latest unstable pre-release\n"
    + "code, you will need to update your URLs (and can do so now).\n"
    + "See the following link for more info, thanks.\n\n"
    + "https://gitlab.com/khumba/nvd/-/issues/19";

  warn = if silenceWarning then lib.id else lib.warn warning;
in
warn (
stdenv.mkDerivation {
  pname = "nvd";
  version = "0.2.4";

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
)
