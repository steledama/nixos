# Valutazione dei delta

Dagli output, individua i pacchetti/immagini con status `↑` (aggiornamento
disponibile). Ignora i bump di patch banali senza note rilevanti; segna come
"da approfondire" i bump minor/major, i pacchetti di sistema critici (kernel,
Docker, Niri, driver hardware).
Per casa applica i [controlli per host](sistema.md).

## Changelog

Non andare sui changelog di tutti i delta: è la parte lenta e non
deterministica della skill, usala con parsimonia. Consulta le release notes
upstream solo quando il delta lo merita:

- bump **major o minor rilevante** (non i patch banali senza note)
- pacchetti **critici per la sicurezza** (browser, kernel, driver, Docker) —
  qui **non saltare** il changelog anche se il salto di versione è piccolo:
  un patch di Chromium/kernel può portare fix di CVE che alzano la priorità
- ogni caso in cui il confronto del ramo selezionato solleva un dubbio concreto
  (breaking change plausibile, migrazione di config sospetta, coda di build)

Per i bump di patch routine di cui non hai dubbi, salta la consultazione e
dichiaralo («patch routine, changelog non consultato»). Non vale per i
pacchetti critici per la sicurezza.

Il rischio di browser e kernel si assegna dopo aver letto la fonte, aperta
con `WebFetch` e non dal riassunto di una ricerca: per Chromium il post
«Stable Channel Update for Desktop» della versione, per il kernel il
`ChangeLog-<versione>` su `cdn.kernel.org`. Se la fonte non si trova, la voce
porta `rischio: non valutato`, con la fonte cercata nella nota, e sale in
`Attenzione:`. Assegnare `medio` senza fonte deciderebbe da solo la mancata
promozione, che scatta sul rischio alto (giro del 2026-11-08,
`i1/ciclo-primo-giro-stadi-20261108.md`).

## Vincoli

Applica autonomia e attivazione del ramo, allineamenti del [contesto](contesto.md)
e, per casa, rischi di [sistema](sistema.md). La colonna cache cerca il path
di riferimento nelle cache configurate per l'host nel checkout: `✗` segnala
compilazioni locali, `!` (accesso negato) e `?` (non verificata) non sono un
verdetto. Per i pacchetti CUDA di game vale il controllo di
[sistema](sistema.md). Controlla i blocchi già tracciati in `o1/plan.md` e
`world.md`.

## Esito

Non un semplice elenco di versioni: per ogni gruppo (ia/home-manager/casa)
rispondi a tre domande — vale la pena aggiornare adesso? cosa aggiornare e in
che ordine? quali rischi (breaking changes, host coinvolti, vincoli di
rebuild/cache)? Segnala esplicitamente i pacchetti da rimandare e perché. Cita
la freschezza calcolata nel [contesto](contesto.md) (in linea/anticipato/in ritardo rispetto
alla `cadenza_giorni` di quella voce): un ramo **in ritardo** alza la priorità
dell'aggiornamento, uno **anticipato** senza un motivo concreto (CVE, delta
critico) va segnalato come tale — il bilanciamento aggiornamento/stabilità
passa da qui, non da un'esecuzione automatica sul solo status `↑`. Per
`casa`, elenca esplicitamente lo stato di `applicato_su` rispetto
agli host del gruppo (chi ha già fatto il rebuild su questo `nixpkgs_rev`,
chi resta pendente) — non ripetere la diagnosi per ogni host, riportane
solo lo stato di attivazione — più l'eventuale deriva di configurazione
dell'host corrente ([contesto](contesto.md)), anche quando `applicato_su` lo include.

Per le fonti usa [upstream](references/upstream.md), leggendo solo quelle
pertinenti. Il ramo ia specifica la propria regola per patch e minor.
