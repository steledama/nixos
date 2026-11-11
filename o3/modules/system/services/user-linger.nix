# modules/system/services/user-linger.nix
#
# Enable systemd user service lingering for specified users
# This ensures user services (like Syncthing) continue running
# even when the user is not logged in
{
  config,
  lib,
  ...
}:
with lib; {
  options.services.userLinger = {
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of users to enable lingering for";
      example = ["stele"];
    };
  };

  config = {
    # Create linger file for each user using tmpfiles
    # This is the declarative way to enable lingering in NixOS
    systemd.tmpfiles.rules = map (user: "f /var/lib/systemd/linger/${user} 0644 root root - -") config.services.userLinger.users;
  };
}
