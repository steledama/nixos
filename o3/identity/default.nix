{
  # Marks the public examples: o3/hosts/default.nix refuses to activate them.
  # The local default.nix must not carry this attribute.
  template = true;
  home = import ./home.example.nix;
  work = import ./work.example.nix;
}
