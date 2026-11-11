---
title: "NixOS in sintesi"
subtitle: "Configurazione dichiarativa dei tre host di casa: una rete, due VPN e un ciclo che la tiene vera."
author: "metodo"
ciclo: runtime
---

## Snello **e** affidabile {.hero}

Due goal in tensione: un sistema minimalista, senza configurazione fuori dal
repository, e tre host replicabili i cui servizi ripartono da soli.
La ridondanza è il prezzo dell'affidabilità; il minimalismo la tiene piccola.

## Tre host, un mondo

::: {.mondi}
::: {.mondo .casa}
**Casa** · LAN `192.168.0.0/24`

- **deck** — laptop, gateway delle due VPN, ciclo autonomo
- **neve** — desktop, media center, scanner
- **game** — GPU: llama.cpp, OCR e trascrizione per la LAN

:::

:::

Un solo flake: `nixpkgs` per sistemi e home, `ai` per lo stack agentico.
La coppia server di lavoro, `norvegia` e `svezia`, vive nel repo
`example-org/nixos-ufficio`.

## La rete

![](assets/rete.svg){.tavola}

## Chi raggiunge cosa

::: {.percorsi}

- **Da casa all'ufficio** — la VPN ufficio di deck, accesa dal boot:
  `ssh svezia` e le presentazioni della production. Solo da deck.
- **Dal telefono** — la VPN casa fino a deck (`10.20.0.1`), poi da lì.
- **Dall'ufficio a casa** — solo lo standby, col tunnel casa ad avvio manuale.

:::

Ogni nome host risolve allo stesso indirizzo ovunque compare
(`host-names.nix`; i nomi dell'ufficio solo su deck).
SSH non è mai esposto sulla WAN e accetta solo chiavi.

## Livelli di configurazione

- **Sistema** — `o3/hosts/` e `o3/modules/system/`: si applica con
  `nixos-rebuild` e serve `sudo`.
- **Utente** — `o3/home/` e `o3/modules/home/`: `home-manager switch`, che
  l'agente esegue da sé.
- **Identità** — IP, chiavi pubbliche, endpoint in `~/.config/nixos/identity/home.nix`,
  separati dalla struttura; `work.nix` tiene solo ciò che serve a deck verso
  l'ufficio.
- **Segreti** — fuori da Git, inventariati in `kb/secrets-management.md`.

## Il ciclo

::: {.ciclo}
[**eval**<br>percepire, interpretare, confrontare col Goal]{.passo}
[→]{.freccia}
[**exec**<br>pianificare, specificare, eseguire]{.passo}
[→]{.freccia}
[**commit**<br>controlli, filing back, push]{.passo}
:::

Ogni notte alle 04:30 deck fa un giro senza custode e lascia il resoconto.
A ogni commit le viste si ripubblicano in LAN dalla porta 8002 di deck.

## Sorgenti

- `goal.md` e `world.md` — i due goal e il polo-territorio.
- `kb/network-architecture.md`, `kb/wireguard-home.md`, `kb/ssh-matrix.md`
  — rete, VPN e percorsi.
- `kb/client-desktop-architecture.md` — ruoli dei tre host di casa.
