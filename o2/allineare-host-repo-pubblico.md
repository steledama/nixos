---
sintesi: "Predisporre le identità locali su game e neve e sostituire i vecchi checkout con clone della storia pubblica, conservando il passato privato."
ciclo: runtime
---

# Allineare game e neve al repo pubblico

## Contesto

Il custode ha deciso il 2026-11-11 di mantenere un solo repo operativo di
casa pubblico, con storia nuova. Il vecchio repo GitHub è stato rinominato
`nixos-archivio-privato` e archiviato mantenendolo privato; non si sincronizza.
Su deck la nuova storia sostituisce i metadati Git, con il vecchio `.git`
conservato nell'archivio privato. Sistemi NixOS invariati; home di deck
applicata e verificata durante la preparazione.

Game e neve devono ricevere l'identità locale prima di usare il nuovo
flake. Dalla storia precedente non è possibile un normale pull fast-forward.
Questi atti si compiono in una sessione sull'host o dal terminale del
custode: `remoto allinea` non predispone le identità e non sostituisce una
storia divergente. Nessun atto remoto è stato eseguito dalla pubblicazione.

## Procedura su ciascun host

1. Conservare il vecchio checkout e cambiare il suo origin verso l'archivio
   privato, evitando che tenti di aggiornare il nuovo repo pubblico.
2. Predisporre `~/.config/nixos/identity/{default,home,work}.nix` coi dati
   reali, come su deck (stessa infrastruttura); directory `0700`, file
   `0600`. I valori si trasferiscono nel canale privato del custode, non
   nel repository o nella chat. Predisporre anche il controllo privacy
   locale descritto in `o3/identity/README.md`.
3. Spostare il vecchio checkout a un nome privato riconoscibile, senza
   sovrascrivere directory già esistenti. Clonare il repo pubblico in
   `~/nixos`; il vecchio checkout non va unito né ripushato nel nuovo.
4. Da `~/nixos`, applicare la home col proprio host:
   `o3/scripts/con-identita.sh home-manager switch --flake .#stele@<host>`.
5. Verificare SSH, mount Drive, Syncthing e unità utente; provare il
   controllo della deriva home e il normale ciclo di manutenzione.

Il sistema attivo conserva una revisione della storia privata:
`system-drift.sh` può dichiararla non misurabile nel clone pubblico fino al
prossimo rebuild ordinario. La separazione è stata confrontata prima del
taglio: i tre derivation path di sistema con revisione fissata sono
identici. Nessun rebuild è implicito nella pubblicazione.

## Chiusura

Entrambi gli host hanno identità locali, clone pubblico in `~/nixos`, home
applicata e verificata. Il vecchio materiale rimane privato; non esiste una
seconda copia operativa da sincronizzare.
