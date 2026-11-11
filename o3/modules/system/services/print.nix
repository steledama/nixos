{pkgs, ...}: {
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [pkgs.foomatic-db pkgs.gutenprint pkgs.hplip];
  };
}
