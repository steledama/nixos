{ pkgs, ... }:
{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.foomatic-db-nonfree pkgs.gutenprint pkgs.hplip ];
  };
}

