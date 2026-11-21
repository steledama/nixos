# modules/home/herdr.nix
# Herdr: agent multiplexer (orchestratore di agenti AI nel terminale).
# Multiplexer terminale principale (ha sostituito zellij).
# Docs: https://herdr.dev/docs/  •  pacchetto da pkgs-ai (non dal flake upstream),
# cosi' segue la cadenza quotidiana degli agenti che orchestra.
{pkgs-ai, ...}: {
  home.packages = [pkgs-ai.herdr];

  # Config raw TOML: herdr non ha un modulo home-manager dedicato.
  # Genera il default aggiornato con: herdr --default-config
  xdg.configFile."herdr/config.toml".text = ''
    # Config gestita da Nix: la modifica va fatta nel modulo, non a mano.
    onboarding = false

    [theme]
    # Coerenza con il resto del sistema (Catppuccin Mocha)
    name = "catppuccin"

    [keys]
    # Prefisso su tasto funzione: tasto singolo, zero collisioni con i ctrl
    # di fish/helix/fzf/Claude e non bindato in niri/foot. Usato di rado
    # perche' le dirette qui sotto fanno il grosso del lavoro.
    prefix = "f12"

    # Sintassi ARRAY = piu' bind per azione: teniamo i default con prefisso
    # E aggiungiamo le dirette, senza che una sostituisca l'altra.
    # Nuovo e chiudi tab su ctrl+alt, libero su niri (occupa solo ctrl+alt+s
    # e ctrl+alt+delete); la navigazione segue il browser.
    new_tab            = ["prefix+c", "ctrl+alt+n"]       # nuovo tab
    close_tab          = ["prefix+shift+x", "ctrl+alt+x"] # chiudi tab
    # Tab come nel browser: ctrl+tab avanti, ctrl+shift+tab indietro.
    # Libere su niri, foot, fish, helix e Claude Code.
    next_tab           = ["prefix+n", "ctrl+tab"]         # tab seguente
    previous_tab       = ["prefix+p", "ctrl+shift+tab"]   # tab precedente
    # ctrl+su/giu': niri li usa solo con Mod, fish/helix/Claude Code no.
    previous_workspace = "ctrl+up"                        # workspace precedente
    next_workspace     = "ctrl+down"                      # workspace seguente
    detach             = "prefix+q"                       # stacca il client; dal telefono si chiude la connessione SSH
  '';
}
