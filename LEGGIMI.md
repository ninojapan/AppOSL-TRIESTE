# Gestione O.S.L. Nave TRIESTE

Web app locale per la gestione dello store di bordo (O.S.L.). Nessuna dipendenza
esterna: usa solo **PowerShell** integrato di Windows + un browser. Stessa
meccanica di avvio del progetto GEPA MASTER.

## File della cartella

| File | Descrizione |
|------|-------------|
| `APRI_APP.bat` | **Avvio quotidiano** — doppio clic: chiude i server residui, apre il browser e avvia il server minimizzato. |
| `start-server.bat` | Avvio manuale del solo server (utile per debug o percorsi di rete UNC). |
| `server.ps1` | Server HTTP in PowerShell puro su `http://localhost:5030`. |
| `OSL TRIESTE.html` | L'app single-file (HTML + CSS + JS). |
| `logo.png` | **da aggiungere tu**: lo stemma della nave mostrato in alto a sinistra. |
| `OSL TRIESTE.json` | Dati principali (creato in automatico). |
| `OSL TRIESTE.json.backup` | Copia di sicurezza creata ad ogni salvataggio. |
| `OSL TRIESTE local.json` | Dati leggeri/frequenti (scontrino in corso). |

## Come si avvia

1. Copia l'intera cartella su un PC **Windows**.
2. Salva lo stemma della nave come **`logo.png`** in questa cartella (stesso
   nome, tutto minuscolo). L'app lo mostra in alto a sinistra.
3. Doppio clic su **`APRI_APP.bat`**.
4. Si apre Microsoft Edge su `http://localhost:5030`. Se non si apre da solo, vai a
   quell'indirizzo con qualunque browser.
5. Per chiudere: chiudi la finestra PowerShell minimizzata.

> La porta è la **5030**. Per cambiarla modifica `$Port` in `server.ps1`,
> l'indirizzo in `APRI_APP.bat` e riavvia.

## Come si usa

- **Pannello sinistro — Nuovo prodotto / Carico**: denominazione, codice a barre,
  quantità, scadenza, prezzo, categoria e immagine. Se denominazione o codice
  coincidono con un prodotto esistente, la quantità entra come **nuovo lotto** con
  la sua scadenza → in inventario vedrai più scadenze con le rispettive rimanenze.
- **Cassa (lettore)**: il lettore di codici a barre è sempre in ascolto. Alla
  scansione si apre una finestra per la **quantità**; premi **Invio** per aggiungere
  allo scontrino. Se **non** premi Invio e scansioni un altro prodotto, quello
  precedente viene aggiunto (1 pezzo, o i pezzi accumulati scansionandolo più volte)
  e si passa al nuovo prodotto — come al supermercato. Codici non a catalogo vengono
  precompilati nel form prodotto.
- **Vendita manuale**: griglia dei prodotti con immagini; clic → scelta quantità →
  Invio.
- **INCASSA (F2)**: chiude lo scontrino, registra la vendita, scala il magazzino
  (le scadenze più vicine per prime, FIFO) e aggiorna gli incassi.
- **Registro di cassa**: elenco delle vendite, con modifica ed eliminazione ordine
  (il magazzino viene ripristinato/riadeguato di conseguenza).
- **Statistiche**: per tipologia, prodotti più venduti, incasso ultimi 14 giorni.
- **Incasso**: oggi, ieri, ultimi 7/30 giorni, questo mese o periodo personalizzato
  (dal → al), con dettaglio per giorno.

I dati sono salvati automaticamente su disco in UTF-8 (senza BOM). Da sinistra puoi
anche **esportare/importare** un backup `.json`.
