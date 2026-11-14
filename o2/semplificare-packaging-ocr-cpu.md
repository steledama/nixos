---
sintesi: "Riesaminare le personalizzazioni di packaging Paddle CPU quando nixpkgs/PaddleX consentono un runtime locale con modelli fissati e sole dipendenze di inferenza."
ciclo: runtime
---

# Semplificare il packaging OCR CPU dopo il supporto upstream

## Costo locale

La ricetta `o3/modules/home/ocr-cpu/package.nix` limita PaddleOCR alle
dipendenze di inferenza, usa le wheel ufficiali collaudate di PaddlePaddle,
OpenCV, safetensors e hf-xet e rende opzionali gli import dei downloader
ModelScope e AIStudio in PaddleX. Il primo è segnalato vulnerabile nel pin,
il secondo è unfree; nessuno serve con i modelli locali fissati nello store.
Le wheel evitano build native e dipendenze Torch/Triton dei test upstream
estranei a questa pipeline. Il test locale senza rete resta obbligatorio.

## Risveglio e chiusura

`w3`: al cambio del pin nixpkgs o di PaddleX, in sessione, verificare se le
ricette upstream offrono le dipendenze minime e importano PaddleX senza i
downloader esclusi. In tal caso ridurre o rimuovere le personalizzazioni
corrispondenti, conservando i modelli fissati e il contratto `ocr-cpu`.

La patch degli import esce quando PaddleX gestisce da sé l'assenza dei due
provider. Gli override delle wheel escono quando il percorso Nix ordinario
rispetta il runtime necessario senza compilazioni sproporzionate. Non
sostituire una personalizzazione con un'autorizzazione a pacchetti vulnerabili
o unfree inutilizzati. Ricostruire e passare il test senza rete; nessuna
necessità di ripetere il confronto sul PDF per la sola semplificazione.

## Connessioni

- [game-local-llm](../kb/game-local-llm.md)
- [workaround-desktop-upstream](../i3/workaround-desktop-upstream.md)
- [plan](../o1/plan.md)
