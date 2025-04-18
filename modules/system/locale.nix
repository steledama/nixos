# modules/system/locale.nix
{
  # Time settings
  time = {
    timeZone = "Europe/Rome"; # Italian timezone
    hardwareClockInLocalTime = true; # Hardware clock in local time (helps with dual boot)
  };

  # Default locale: main system language (menus, etc)
  i18n.defaultLocale = "it_IT.UTF-8";

  # Detailed locale settings for various categories
  # All set to Italian for consistent regional formatting
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8"; # Address formats
    LC_IDENTIFICATION = "it_IT.UTF-8"; # Language/region identification
    LC_MEASUREMENT = "it_IT.UTF-8"; # Measurement units (metric)
    LC_MONETARY = "it_IT.UTF-8"; # Currency formats (€)
    LC_NAME = "it_IT.UTF-8"; # Name formats
    LC_NUMERIC = "it_IT.UTF-8"; # Number formats (decimal comma)
    LC_PAPER = "it_IT.UTF-8"; # Paper size (A4)
    LC_TELEPHONE = "it_IT.UTF-8"; # Telephone number formats
    LC_TIME = "it_IT.UTF-8"; # Date and time formats (DD/MM/YYYY)
  };
}
