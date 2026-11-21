# presentations.nix
#
# Registry of project presentations served on the private networks
# (kb/deck-user-services.md § Presentazione sulla LAN). Single source of
# truth for the ports: the home module modules/home/presentations.nix reads
# which repo to serve where, the host firewalls read which ports to admit.
# A group site (method kb/view-publishing.md § Sito di gruppo) replaces the
# ports of its members: they publish, the group server routes /<repo>/.
{
  # Default port of serve.py when launched by hand, on every host.
  manualPort = 8000;

  # Permanent services of a single repo, by privileged host: repo name
  # (checkout in ~) -> port. method is the canon, never a group member.
  privileged = {
    deck = {
      method = 8001;
    };
  };

  # Group sites, by privileged host: instance repo -> port. The instance's
  # world.md (## Membri) declares the members; /adottanti of method checks
  # that they match the published repos without a port of their own.
  groups = {
    deck = {
      casa = 8002;
    };
  };

  # Repos served in the published form (method prescription viste-fuori-da-git):
  # build.py --publish builds the checkout's HEAD from a clean commit into a
  # folder outside the checkout, and serve.py --publish-root serves it.
  published = ["method" "casa" "nixos" "salute" "economia"];
}
