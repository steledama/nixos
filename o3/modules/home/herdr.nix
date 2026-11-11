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
    # perche' le dirette ctrl+alt qui sotto fanno il grosso del lavoro.
    prefix = "f12"

    # Sintassi ARRAY = piu' bind per azione: teniamo i default con prefisso
    # E aggiungiamo le dirette ctrl+alt, senza che una sostituisca l'altra.
    # ctrl+alt e' libero su niri (occupa solo ctrl+alt+s e ctrl+alt+delete):
    # nessuna delle combinazioni sotto collide con il compositor.
    new_tab            = ["prefix+c", "ctrl+alt+n"]       # nuovo tab
    close_tab          = ["prefix+shift+x", "ctrl+alt+x"] # chiudi tab
    next_tab           = ["prefix+n", "ctrl+alt+right"]   # tab seguente
    previous_tab       = ["prefix+p", "ctrl+alt+left"]    # tab precedente
    previous_workspace = "ctrl+alt+up"                    # workspace precedente
    next_workspace     = "ctrl+alt+down"                  # workspace seguente
    detach             = "prefix+q"                       # stacca il client; dal telefono si chiude la connessione SSH
  '';
}
