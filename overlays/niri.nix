# overlays/niri.nix
# Questo file fornisce Niri se non è disponibile in nixpkgs
{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, ninja
, cmake
, wayland
, wayland-protocols
, cairo
, libdisplay-info
, libliftoff
, libinput
, libseat
, libxkbcommon
, pipewire
, dbus
, udev
, xorg
, mesa
, abseil-cpp
, libGL
, vulkan-loader
, vulkan-validation-layers
, systemdMinimal
, ...
}:

stdenv.mkDerivation rec {
  pname = "niri";
  version = "25.02";  # Aggiornato all'ultima versione stabile

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = "niri";
    rev = "v${version}";
    hash = "sha256-URjjxImQN4tcUfzpDy8NK1MVMS99EaGgc0HodLB7oHg=";  # Aggiorna questo hash quando necessario
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    cmake
    wayland
  ];

  buildInputs = [
    wayland
    wayland-protocols
    cairo
    libdisplay-info
    libliftoff
    libinput
    libseat
    libxkbcommon
    pipewire
    dbus
    udev
    xorg.libX11
    xorg.libxcb
    xorg.xcbutilwm
    xorg.xcbutilrenderutil
    xorg.xcbutilerrors
    abseil-cpp
    libGL
    vulkan-loader
    systemdMinimal
  ];

  mesonFlags = [
    "-Dman-pages=disabled"  # Salta la generazione delle pagine man per ridurre le dipendenze
  ];

  # Crea un file desktop appropriato per i display manager
  postInstall = ''
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/niri.desktop << EOF
    [Desktop Entry]
    Name=Niri
    Comment=Un compositore tiling per Wayland
    Exec=$out/bin/niri
    Type=Application
    EOF
  '';

  meta = with lib; {
    description = "Compositore tiling per Wayland con scorrimento";
    homepage = "https://github.com/YaLTeR/niri";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    mainProgram = "niri";
  };
}
