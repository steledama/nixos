{ pkgs, config, ... }:

{
  home.file.".config/neofetch/config.conf".text = ''
    print_info() {
        info "  OS " distro
        info underline
        info "  VER" kernel
        info "  UP " uptime
        info "  PKG" packages
        info "  DE " de
        info "  TER" term
        info "  CPU" cpu
        info "  GPU" gpu
        info "  MEM" memory
        prin " "
        prin "       "
    }
    distro_shorthand="on"
    memory_unit="gib"
    cpu_temp="C"
    separator=" >"
    stdout="off"
    
    # Disable the large ASCII logo but keep small icons
    image_backend="off"
    image_source="auto"

    # Customize the appearance
    bold="on"
    underline_enabled="on"
    underline_char="-"
    separator=" >"

    # Colors for text
    colors=(distro)
    
    # Customize info display
    package_managers="on"
    os_arch="on"
  '';
}
