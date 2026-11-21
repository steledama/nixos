---
stato: maturo
---

# Game Strata trial

Prova in area utente del motore Strata su `game`, per far girare
Qwen3.8-Flash-Next, un MoE da 177B, che il servizio llama.cpp non regge con
prestazioni utili. È un esperimento reversibile, fuori dalla configurazione
ordinaria, valutato col criterio delle prove di `game-local-llm`: entra nel
servizio solo se misura, qualità e costo di manutenzione lo giustificano.

## Misure e decisione

Qwen3.8-Flash-Next (MoE 177B) gira solo su Strata IQ3_XXS low-RAM a
contesto 64K (decisione del custode, 2026-10-07). A decidere è il prefill:
un agente come pi rilegge 30–50K token a ogni passo. Misure su `game` (48
GB, RTX 4070; bench e run in `~/llm-bench`, fuori dal repo), a cache calda:

- Strata IQ3_XXS low-RAM: prefill circa 2000 tok/s, decode circa 50 tok/s,
  48K token letti in 29 s; RAM disponibile circa 3 GB, swap leggero;
- llama.cpp `UD-IQ3_XXS` (`cpu-moe`, esperti in RAM via mmap): prefill circa
  150 tok/s (54 a freddo), decode circa 18 tok/s, circa 5 minuti per la
  stessa lettura, swap continuo. Con 64 GB sparirebbe lo swap, non la
  lentezza del prefill.

Per questo il preset Flash-Next di llama.cpp è stato rimosso dal servizio il
2026-10-08 insieme ai suoi tre frammenti GGUF (circa 77 GB nello store): il
preset, i pin e le misure restano nella storia archiviata in privato su
`deck` (`o3/identity/README.md`, «Storia precedente»). llama.cpp resta per
il 27B denso e per MiniCPM-OCR. Strata resta però fuori dal servizio, come prova
in area utente (decisione del custode, 2026-10-08):

- avvio a mano con `~/Strata/run.sh` (porta 18080, solo locale), che ferma
  `llama-cpp.service` se attivo (con sudo); con Strata acceso la GPU è sua,
  quindi niente 27B, MiniCPM-OCR, Whisper o gioco;
- checkout su `main` di upstream, oggi `v0.2.9` (motore 0.1.55),
  compilato con CUDA 13.0 di nixpkgs (GC root `~/Strata/.cuda-env`,
  ambiente in `~/Strata/nixos-env.sh`), pesi, pack ed `experts.bin` in
  `~/Strata-data`; da `v0.1.39` a `v0.2.9` il pack è rimasto
  `FORMAT_VERSION = 1` e `experts.bin` non è stato rigenerato. Misura del
  2026-11-01 dopo l'aggiornamento: 39K token in 19 s (prefill circa 2000
  tok/s), decode circa 55 tok/s, RAM disponibile circa 1 GB;
- nel repo c'è solo la compattazione di pi per il modello
  `strata/qwen3.8-flash-next-iq3_xxs-64k` (`o3/modules/home/pi.nix`); se
  l'id del modello cambia, l'override smette di applicarsi senza errori.

Perché non un pacchetto Nix né un container:

- upstream molto giovane: 46 tag in circa due settimane, più al giorno, e
  il 2026-10-08 un force push ha riscritto storia e tag (`v0.1.39` da
  `6f32ec0` a `a1641e9`, stessi file): un pin per commit può sparire dal
  remoto;
- costo stimato il 2026-10-06: pacchetto Nix 2–4 giorni e 1–3 ore per
  aggiornamento; container mezza giornata o una e circa un'ora per
  aggiornamento, ma senza pin per hash di immagine e pesi;
- il costo ricorrente maggiore non è il packaging ma la GPU esclusiva, da
  coordinare con il router llama.cpp, Whisper, MiniCPM-OCR e il gioco.

L'aggiornamento è diretto, sul posto (decisione del custode, 2026-11-01:
il contesto è sperimentale, senza dati da perdere né utenti del servizio):
fermare llama.cpp, poi `cd ~/Strata && . ./nixos-env.sh && ./update.sh`,
che fa `git pull --ff-only`, ricompila il motore e aggiorna `.venv` e
settings dei modelli senza toccare i pesi. Se un cambio di formato del pack
chiede di rigenerare `experts.bin` (circa 40 GiB), lo si accetta. L'integrazione
torna un task quando valgono insieme tre condizioni: upstream smette di
riscrivere la storia e rallenta i rilasci, Strata diventa il motore d'uso
quotidiano, e la condivisione della GPU è decisa. Un fork o mirror del
repo tiene disponibile il commit in uso, qualunque cosa faccia upstream.

Connessioni:

- [game-local-llm](game-local-llm.md)
- [hardware-inventory](hardware-inventory.md)
- [client-desktop-architecture](client-desktop-architecture.md)
