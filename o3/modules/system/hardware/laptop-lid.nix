{
  # Let the compositor handle the laptop panel on lid events.
  # systemd-logind must not suspend the machine when the lid is closed.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
