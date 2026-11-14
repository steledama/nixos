---
title: "NixOS: la casa, il codice e la sua cura"
subtitle: "Tre computer con ruoli diversi, una configurazione riproducibile e un ciclo di manutenzione supervisionato."
author: "metodo"
ciclo: runtime
---

## La cura dei computer di casa {.hero}

Computer piacevoli da usare, puliti, aggiornati e sicuri. Una configurazione
che si capisce e si ricostruisce senza dipendere dalla memoria.

Codice, documentazione e manutenzione supervisionata servono questo scopo.

## Quattro obiettivi, scelte concrete

- **Semplicità e pulizia:** ogni componente ha un'utilità e un costo accettabile.
- **Riproducibilità e controllo:** sapere cosa è attivo, ricostruirlo e tornare indietro.
- **Aggiornamento consapevole:** conoscere le novità, scegliere e verificarne l'applicazione.
- **Sicurezza e riservatezza:** controllare accessi, esposizione, credenziali e dati.

L'affidabilità quotidiana attraversa tutti e quattro. I tre computer hanno
ruoli diversi; non devono sostituirsi a vicenda.

## Tre computer, responsabilità diverse

::: {.schede}
::: {.scheda}
**deck · il punto di continuità**

Portatile e piccolo server: VPN casa, collegamento all'ufficio,
pagine dei progetti e cicli autonomi.
:::
::: {.scheda}
**neve · il desktop domestico**

Media center, scanner, audio e monitor. Una postazione adattata
alle periferiche e all'uso quotidiano.
:::
::: {.scheda}
**game · gioco e GPU**

Gaming, modelli locali per chat e OCR, strumenti di trascrizione.
La GPU è una risorsa da condividere fra questi usi.
:::
:::

Stesso desktop Niri e strumenti comuni; configurazioni specifiche per ogni host.

## Una configurazione, tre applicazioni

Il **flake** è l'ingresso: dichiara host, profili e dipendenze fissate
nel lock. I moduli comuni evitano di ripetere le stesse scelte.

- **Sistema:** hardware, driver, rete e servizi in `o3/hosts/` e
  `o3/modules/system/`. Si applica con `nixos-rebuild`, con autorizzazione.
- **Utente:** shell, strumenti e servizi personali in `o3/home/` e
  `o3/modules/home/`. Si applica con Home Manager.
- **Differenze:** ogni host e profilo aggiunge ciò che gli serve alla base comune.

Un commit registra una modifica; lo switch la rende attiva sull'host.

## Struttura pubblica, identità locale

Il repository contiene la struttura e template pubblici. Indirizzi,
account ed endpoint reali arrivano da file locali di identità.

- Il wrapper `con-identita.sh` collega quei dati ai comandi di build e switch.
- Credenziali e chiavi private restano fuori da Git.
- Inventario, seed dei segreti e procedura di ripristino completano il codice.

**Ricostruire un computer richiede repository, identità e segreti:**
la prova del seed è una ricorrenza annuale.

## La rete collega ruoli e confini

![](assets/rete.svg){.tavola}

## File locali e Drive seguono strade diverse

**Syncthing** sincronizza `~/sync/` direttamente fra deck, neve e game:
una rete fra pari, senza un computer centrale obbligatorio.

**Rclone** monta Google Drive su ciascun host in `~/Drive/`:
i file remoti sono accessibili senza una copia locale completa.

I servizi utente e le dipendenze dei mount sono dichiarati per ripartire
anche dopo login e manutenzione. Sincronizzazione, accesso al cloud e
ripristino hanno procedure distinte.

## La GPU di game serve anche gli altri progetti

`llama.cpp` offre chat e OCR alle reti private. Il workflow OCR di
`economia` usa quel servizio; prompt e trattamento dei documenti restano
nel progetto che li conosce.

- **Infrastruttura in nixos:** servizio, rete, pesi fissati per hash e CUDA.
- **Uso su richiesta:** llama.cpp si avvia manualmente; la GPU serve anche al gioco.
- **Trascrizione:** strumenti Whisper con CUDA, con procedura dedicata.
- **Sperimentazione:** prove come Strata restano in area utente finché
  qualità e costo di manutenzione non ne giustificano l'integrazione.

## Il repository conserva anche le ragioni

- **`goal.md` e `world.md`:** cosa vogliamo ottenere e su quale territorio.
- **`kb/`:** architettura, scelte e procedure di uso e ripristino.
- **`i1/` → `i2/` → `i3/`:** osservazioni, interpretazioni e giudizi sugli obiettivi.
- **`o1/` → `o2/` → `o3/`:** piano, specifiche e configurazione o strumenti che agiscono.

`method` fornisce il metodo e gli strumenti comuni. `nixos` li applica
alla casa, mantenendo qui la conoscenza del proprio sistema.

## Ogni giorno: osservare, decidere, verificare

::: {.ciclo}
[**eval**<br>osservare il sistema e confrontarlo con gli obiettivi]{.passo}
[→]{.freccia}
[**exec**<br>aggiornare il piano e compiere gli atti autorizzati]{.passo}
[→]{.freccia}
[**commit**<br>controllare, registrare le decisioni e pubblicarle]{.passo}
:::

L’obiettivo è ridurre il tempo di manutenzione, mantenendo comprensione e controllo.

Alle **04:30 su deck** il ciclo autonomo controlla salute del sistema,
aggiornamenti e attese upstream, poi lascia resoconto, diff e commit.
Un giro senza aggiornamenti resta utile se conferma lo stato e i limiti osservati.

## Autonomia con confini leggibili

Il giro può aggiornare gli strumenti AI e Home Manager su deck,
verificare e correggere documentazione e pianificazione.

I task di sviluppo restano alle sessioni col custode. Il giro notturno
non agisce su game o neve e non esegue rebuild di sistema, sudo o reboot.
Scopi e condizioni della delega restano decisioni umane.

**Il resoconto permette la supervisione:** esito effettivo, controlli,
costo, dinieghi e questioni aperte. Un push pubblica il codice e le viste;
l'attivazione del sistema è un atto separato.

## Le viste: contenuti locali, programma condiviso

![](assets/viste.svg){.tavola}

## Dalla modifica alla pagina nel browser

`build.py` genera HTML dal commit del progetto e da quello di `method`.
`serve.py` consegna al browser la versione pubblicata.

- **Contenuti nuovi:** la pubblicazione cambia il puntatore alla versione;
  il server li mostra senza riavviarsi.
- **Programma nuovo:** il server deve riavviarsi per caricare il codice aggiornato.
- **Build fallita:** resta disponibile l'ultima versione buona, con errore consultabile.

Su deck la pubblicazione segue i commit e i pull locali, con recupero ogni
cinque minuti. Le pagine sono esposte solo alle reti private.

## Casa e lavoro condividono strumenti, hanno governi distinti

**Questo repo** configura deck, neve e game, compresi i servizi che deck
ospita per `method`, `nixos`, `salute` ed `economia`.

**Il repo NixOS di lavoro** configura svezia come server e norvegia come
postazione di sviluppo. Svezia ospita le viste di `bi`,
`nixos` di lavoro e `baserow`.

**danea-auto** configura il proprio avvio su Windows: un task pianificato
lancia il programma comune senza aprire finestre e verifica la pubblicazione
ogni cinque minuti.

Il codice delle viste è condiviso tramite una copia di `method` su ciascun
host. I contenuti, le porte e le responsabilità restano dei rispettivi progetti.

## Come verificare che il racconto sia vero

La configurazione dichiara ciò che deve esserci. Drift, journal e generazioni
attive dicono ciò che è applicato; i controlli della KB cercano incoerenze.

- **Architettura:** `world.md`, `kb/client-desktop-architecture.md`,
  `kb/network-architecture.md`, `kb/syncthing-architecture.md`.
- **Servizi e ripristino:** `kb/game-local-llm.md`, `kb/deck-user-services.md`,
  `kb/secrets-management.md`.
- **Governo:** `autonomy.md`, `kb/cicli.md`, `o1/plan.md` e fili `i3/`.

Il piano e le pagine dei giri tengono lo stato corrente. Questa presentazione
spiega il progetto e le relazioni che permettono di leggerlo.
