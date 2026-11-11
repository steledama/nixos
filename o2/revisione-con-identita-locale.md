---
sintesi: "Ripristinare la tracciabilità della revisione pubblica con l'override dell'identità locale, senza dichiarare pulite build modificate né pubblicare dati privati."
ciclo: runtime
---

# Ripristinare la revisione con identità locale

## Difetto e riscontro

Il rebuild di game riportato dal custode il 2026-11-11 è riuscito: cache CUDA
attiva, Whisper CLI `1.9.5-dev`, nessuna unità fallita. Il sistema registra
però `system.configurationRevision = "dirty"`, mentre il checkout è pulito
a `2c6fa49`; `system-drift.sh` non può confrontarlo con HEAD.

Controprova su deck, stesso checkout pulito: la valutazione senza override
restituisce la revisione completa `2c6fa4982597618a9e6ee8723b4f80977bee91c9`.
Con `con-identita.sh`, `self.rev` e `self.dirtyRev` non sono disponibili e
il fallback in `o3/hosts/default.nix` restituisce `dirty`. I metadati di
`nix flake metadata` conservano invece la revisione pubblica. Il problema
è riprodotto senza build o attivazioni su deck.

## Intervento

Definire e verificare un modo esplicito per conservare la provenienza del
codice pubblico quando il flake riceve l'identità locale. Non limitarsi a
sostituire `dirty` con l'HEAD corrente: occorre distinguere una sorgente
pulita, una modificata e una revisione storica richiesta dal controllo
della deriva. Le identità locali non appartengono al commit pubblico e
la loro provenienza deve restare distinguibile, senza esporne i valori.

Verificare wrapper, modulo di sistema e controlli di deriva; mantenere il
lock pubblico privo di percorsi e dati privati. Provare almeno: checkout
pulito, modifiche locali, revisione precedente con override, identità
locale modificata e identità assente. Aggiornare documentazione e test.
Non ampliare i permessi del ciclo autonomo implicitamente.

## Chiusura

La valutazione conserva la provenienza corretta e le differenze
dell'identità locale non diventano falsi allineamenti. Dopo il rebuild
autorizzato, la revisione attiva e il controllo della deriva tornano
interpretabili. Nessun sudo o rebuild è autorizzato da questo task.
