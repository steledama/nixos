# pkgs/msty.nix
#
# Msty AppImage packaging for NixOS
#
# How to update this package:
# 1. Check if a new version is available (current: 1.8.1)
# 2. Calculate the new hash using one of these methods:
#    - For SRI format: nix-prefetch-url --type sha256 https://assets.msty.app/prod/latest/linux/amd64/Msty_x86_64_amd64.AppImage
#    - OR convert base32 to SRI format: nix hash convert --to-sri --type sha256 THE_BASE32_HASH
# 3. Update the version number and hash below
# 4. Rebuild your system: sudo nixos-rebuild switch --flake .
{
  appimageTools,
  fetchurl,
  makeWrapper,
}: let
  pname = "msty";
  version = "1.8.4"; # Update this when a new version is released
  src = fetchurl {
    url = "https://assets.msty.app/prod/latest/linux/amd64/Msty_x86_64_amd64.AppImage";
    hash = "sha256-4NjS9/ZlzFWyVHA054DmpHeTl35PgkPiHwgRjHeB4is=";
  };
  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;
    nativeBuildInputs = [makeWrapper];
    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/msty.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/msty.desktop \
              --replace 'Exec=AppRun' 'Exec=${pname}'
      install -m 444 -D ${appimageContents}/msty.png \
              $out/share/icons/hicolor/256x256/apps/msty.png
      wrapProgram $out/bin/${pname} \
              --set XDG_CURRENT_DESKTOP GNOME
    '';
  }
