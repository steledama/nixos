# nixos/modules/home/syncthing.nix
#
# User service configuration for Syncthing
# IMPORTANT: After system setup, run 'sudo loginctl enable-linger <username>'
# to prevent the service from going into timeout/sleep mode.
# See CLAUDE.md > Syncthing Service Recovery for details.
{
  services = {
    syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
    };
  };
}
