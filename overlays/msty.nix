# overlays/msty.nix
final: prev: {
  msty = prev.callPackage ../pkgs/msty.nix {};
}
