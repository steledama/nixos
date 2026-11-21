# Fonti upstream

Radici upstream rapide da provare prima di una ricerca web generica:

- Kernel Linux: `https://www.kernel.org/`, changelog come
  `https://cdn.kernel.org/pub/linux/kernel/vX.x/ChangeLog-X.Y.Z`
- Chromium/Chrome: `https://chromereleases.googleblog.com/search/label/Stable%20updates`
- Docker Engine: `https://docs.docker.com/engine/release-notes/`
- Node.js: `https://nodejs.org/en/blog/release/vX.Y.Z`
- Syncthing: `https://github.com/syncthing/syncthing/releases/tag/vX.Y.Z`
- Zed: `https://zed.dev/releases/stable/X.Y.Z`
- Niri: `https://github.com/YaLTeR/niri/releases/tag/vX.Y.Z`
- Helix: `https://github.com/helix-editor/helix/releases/tag/X.Y`
- Fish: `https://github.com/fish-shell/fish-shell/releases/tag/X.Y.Z`
- Git: `https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/X.Y.Z.txt`
- mpv: `https://github.com/mpv-player/mpv/releases/tag/vX.Y.Z`
- Foot: `https://codeberg.org/dnkl/foot/releases/tag/X.Y.Z`
- Herdr: `https://github.com/ogulcancelik/herdr/releases/tag/vX.Y.Z`
- llama.cpp: `https://github.com/ggml-org/llama.cpp/releases`
- home-manager (nessuna release su `master`): commit tra i due rev con
  `gh api repos/nix-community/home-manager/compare/<vecchio>...<nuovo>
--jq '.commits[].commit.message|split("\n")[0]'`; dopo lo switch,
  `home-manager news` per le novità dei moduli in uso
- gogcli (upstream reale, non nixpkgs): `gh release list --repo openclaw/gogcli --limit 1`
- NAPS2: `https://github.com/cyanfish/naps2/releases/tag/vX.Y.Z`
- Docker Hub immagini: `https://hub.docker.com/r/<namespace>/<image>/tags`
  oppure, per immagini ufficiali, `https://hub.docker.com/_/<image>/tags`
