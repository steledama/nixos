---
stato: maturo
---

# Disaster recovery

Runbook per recuperare un host NixOS non avviabile usando una live USB e il
flake del repository. La sorgente di verità resta Git: non copiare la
configurazione in `/etc/nixos`.

## Prima di iniziare

- avvia una live USB NixOS;
- identifica con certezza root ed EFI tramite filesystem, label e dimensione;
- se devi solo salvare dati, copiali prima di tentare un rebuild;
- adatta sempre i device agli output reali: gli esempi non sono un inventario.

```bash
lsblk -f
```

## Montare il sistema

Esempio NVMe:

```bash
sudo mount /dev/nvme0n1p2 /mnt
sudo mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

Esempio SATA:

```bash
sudo mount /dev/sda2 /mnt
sudo mount --mkdir /dev/sda1 /mnt/boot
```

Monta eventuali filesystem separati (`/home`, dati) nei rispettivi punti sotto
`/mnt` prima di entrare nel sistema.

## Entrare e verificare

```bash
sudo nixos-enter --root /mnt
hostname
ls /home
```

Se manca Git, apri una shell temporanea:

```bash
nix-shell -p git
```

Individua il clone del repository dell'utente corretto e verifica il suo stato:

```bash
cd /home/<utente>/nixos
git status
git log --oneline -10
```

Non cambiare commit o branch finché non hai distinto un problema di
configurazione da un guasto di disco, filesystem o bootloader. Se serve tornare
a una revisione nota, preferisci un branch o commit esplicito e annota il punto
di partenza.

## Ricostruire dal flake

In recovery usa normalmente `boot`: prepara la generazione senza tentare di
attivare completamente servizi e sessioni dentro l'ambiente live.

```bash
cd /home/<utente>/nixos
nixos-rebuild boot --flake .#<host>
```

Il target deve essere uno degli host dichiarati nel flake: `deck`, `game` o
`neve`.

Questo stesso comando reinstalla la configurazione di systemd-boot definita per
l'host. Se il problema riguarda soltanto una generazione recente, la strada più
breve resta selezionare dal menu di boot una generazione precedente.

I path del sistema recuperato sono sotto `/mnt` dalla live, oppure assoluti
dentro `nixos-enter`: non seminare chiavi o marker nel filesystem della live.

## Uscire e riavviare

Esci da eventuali shell annidate e da `nixos-enter`, quindi smonta tutto:

```bash
exit
sudo umount -R /mnt
sudo reboot
```

Se `/mnt` è occupato:

```bash
sudo fuser -vm /mnt
```

Chiudi le shell o i processi indicati e ripeti lo smontaggio. Rimuovi la live
USB al riavvio.

## Dopo il recupero

- verifica la generazione attiva e lo stato Git;
- controlla i servizi di sistema e utente falliti;
- per una reinstallazione completa, prosegui da `post-installation`.

```bash
nixos-rebuild list-generations
systemctl --failed
systemctl --user --failed
```

Connessioni:

- [post-installation](post-installation.md)
