---
ciclo: runtime
---

# Avvio di nscd su deck

Il custode ha alzato a 20 il burst di avvio di `nscd` perché le richieste
di `resolvconf` esaurivano il limite precedente. Dopo lo switch
il servizio risultava attivo. L'ipotesi è che il nuovo limite basti anche
durante un avvio ordinario di `deck`.

Il riscontro atteso è un nuovo avvio di `init.scope` seguito da `nscd`
attivo, con il journal di sistema del boot privo di errori per esaurimento
del limite. Un nuovo esaurimento del limite smentirebbe l'ipotesi. Letture
senza boot: 3 su 3, prima il 2026-11-18 e ultima il 2026-11-20 (`uptime -s`:
avvio del 2026-11-15); il servizio era attivo dal 2026-11-17. Il riscontro
resta al prossimo boot, con riesame entro il 2026-12-31 se non si osserva un
nuovo avvio.
