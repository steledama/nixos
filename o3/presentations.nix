# presentations.nix
#
# Registry of project presentations served on the private networks
# (kb/deck-user-services.md § Presentazione sulla LAN). Single source of
# truth for the ports: the home module modules/home/presentations.nix reads
# which repo to serve where, the host firewalls read which ports to admit.
{
  # Default port of serve.py when launched by hand, on every host.
  manualPort = 8000;

  # Permanent services, by privileged host: repo name (checkout in ~) -> port.
  privileged = {
    deck = {
      method = 8001;
      nixos = 8002;
      salute = 8003;
      economia = 8004;
    };
  };

  # Repos served in the published form (method prescription viste-fuori-da-git):
  # build.py --publish builds the checkout's HEAD from a clean commit into a
  # folder outside the checkout, and serve.py --publish-root serves it.
  published = ["method" "nixos" "salute" "economia"];
}
