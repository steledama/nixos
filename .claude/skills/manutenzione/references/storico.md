# Forma del registro

Schema:

```json
{
  "ultima_esecuzione": {
    "data": "YYYY-MM-DD",
    "ora": "HH:MM",
    "host": "<hostname>",
    "rami": ["<rami toccati in questo run>"]
  },
  "ia": {
    "cadenza_giorni": 1,
    "data": "YYYY-MM-DD",
    "ora": "HH:MM",
    "host_eseguito": "<hostname>",
    "esito": "eseguito | nessun_delta | fallito",
    "rev_ai": "<rev input ai, se eseguito>",
    "commit": "<sha locale, se eseguito>",
    "pacchetti": [{ "nome": "...", "da": "...", "a": "..." }],
    "applicato_su": [
      "<host che hanno già fatto home-manager switch su questo rev_ai>"
    ]
  },
  "home-manager": {
    "cadenza_giorni": 7,
    "data": "YYYY-MM-DD",
    "ora": "HH:MM",
    "host_eseguito": "<hostname>",
    "esito": "eseguito | nessun_delta | fallito",
    "rev": "<rev input home-manager nel lock dopo questo run>",
    "nota": "<warning/adeguamenti emersi dalla valutazione delle homeConfigurations>",
    "applicato_su": [
      "<host che hanno già fatto home-manager switch su questo rev>"
    ]
  },
  "casa": {
    "cadenza_giorni": 7,
    "data": "YYYY-MM-DD",
    "ora": "HH:MM",
    "host_controllato": "<hostname del gruppo che ha eseguito system-versions.sh>",
    "nixpkgs_rev": "<rev di flake.lock (input nixpkgs) al momento del check>",
    "esito": "diagnosticato | nessun_delta",
    "pacchetti": [
      {
        "nome": "...",
        "da": "...",
        "a": "...",
        "rischio": "alto | medio | basso | non valutato",
        "nota": "..."
      }
    ],
    "raccomandazione": "...",
    "promosso": "<titolo task in o1/plan.md, o null se nessun finding alto è ancora stato promosso>",
    "applicato_su": [
      "<host del gruppo che hanno già fatto sudo nixos-rebuild switch su questo nixpkgs_rev>"
    ],
    "gogcli": {
      "data": "YYYY-MM-DD",
      "ora": "HH:MM",
      "host_eseguito": "<hostname>",
      "da": "...",
      "a": "...",
      "esito": "aggiornato | nessun_delta",
      "nota": "...",
      "applicato_su": [
        "<host casa che hanno già fatto home-manager switch sul pin corrente>"
      ]
    },
    "host_specifico": {
      "<host>": {
        "pacchetti_dedicati": {
          "<pacchetto compile-pesante host-specifico>": {
            "cadenza_giorni": 30,
            "data": "YYYY-MM-DD",
            "ora": "HH:MM",
            "esito": "nessun_delta | delta_valutato",
            "nota": "..."
          }
        },
        "pacchetti_host": {
          "nixpkgs_rev_valutato": "<nixpkgs_rev di casa al momento dell'ultima revisione delle righe host-esclusive>",
          "data": "YYYY-MM-DD",
          "ora": "HH:MM",
          "esito": "nessun_delta | delta_trovato",
          "pacchetti": [
            {
              "nome": "<pacchetto esistente solo su questo host, es. naps2, steam, heroic>",
              "da": "...",
              "a": "...",
              "rischio": "alto | medio | basso",
              "nota": "..."
            }
          ]
        }
      }
    }
  },
  "world": {
    "<titolo task>": {
      "cadenza_giorni": 30,
      "verifica_attiva_su_cadenza": false,
      "data": "YYYY-MM-DD",
      "ora": "HH:MM",
      "esito": "invariato | chiudibile | da_riverificare",
      "dipendenza": "<issue/URL/condizione citata in Dip. world>",
      "nota": "..."
    }
  }
}
```

Il registro corrente è `i1/manutenzione.json`; lock e allineamento vivono in
`../contesto.md`, le regole di scrittura in `../chiusura.md` e la
granularità nei singoli rami. I valori delle cadenze qui sono esempi,
non default dello script.
