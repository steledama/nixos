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
        prin "       "
    }
    distro_shorthand="on"
    memory_unit="gib"
    cpu_temp="C"
    separator=" >"
    stdout="off"
  '';
}
