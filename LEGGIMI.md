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
| `IMMAGINI/` | **creata in automatico**: qui vengono salvate le foto dei prodotti (non nella cartella principale). |
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

- **Inventario → Nuovo prodotto / Carico** (pannello a sinistra, visibile solo in
  questa sezione): denominazione, codice a barre, quantità, scadenza, prezzo,
  categoria e immagine. Se denominazione o codice coincidono con un prodotto
  esistente, la quantità entra come **nuovo lotto** con la sua scadenza → in
  inventario vedrai più scadenze con le rispettive rimanenze. Le foto caricate
  vengono salvate nella cartella **`IMMAGINI/`**, non sparse nella cartella
  principale.
- **Inventario → filtri**: sopra la tabella puoi filtrare rapidamente su
  **Tutti** / **⏰ In scadenza (30g)** / **🚫 Scaduti** (funzionano insieme alla
  ricerca testuale). Sono cliccabili anche le due KPI corrispondenti in alto
  (ri-cliccarle torna a "Tutti").
- **Inventario → tabella prodotti → ✏️ Modifica**: oltre ai dati anagrafici, il
  modal mostra tutti i **lotti a magazzino** con quantità e scadenza modificabili
  (pulsanti −/+ o digitazione diretta, per correggere/aumentare un lotto già
  esistente) e permette di **aggiungere un nuovo lotto** con una scadenza diversa
  senza dover ridigitare nome/codice del prodotto. Le modifiche ai lotti vengono
  applicate al clic su "Salva".
- **Cassa (lettore o clic manuale — un solo pannello)**: la stessa schermata
  gestisce sia le scansioni che l'aggiunta manuale con un clic sul prodotto. Il
  lettore di codici a barre è **sempre attivo**, in qualunque punto dell'app
  abbia il focus (es. anche mentre stai digitando la quantità o cercando un
  cliente) — non serve mai ricliccare sul campo apposito. Alla scansione o al
  clic si apre una finestra per la **quantità**; premi **Invio** (o clicca
  "Aggiungi") per confermarla nello scontrino, oppure digita la quantità a mano.
  Se scansioni di nuovo lo **stesso** codice, la quantità aumenta; se scansioni
  un codice **diverso**, il prodotto precedente viene registrato nello scontrino
  con la quantità impostata fino a quel momento e si passa al nuovo prodotto —
  esattamente come alla cassa di un supermercato. Premendo **INCASSA/F2**
  l'eventuale prodotto ancora "in sospeso" viene registrato automaticamente
  prima di chiudere lo scontrino. Codici non a catalogo vengono precompilati
  nel form prodotto (sezione Inventario).
- **INCASSA (F2)**: chiude lo scontrino, registra la vendita, scala il magazzino
  (le scadenze più vicine per prime, FIFO), aggiorna gli incassi e la cassa torna
  subito pronta per il cliente successivo.
- **Registro di cassa**: elenco delle vendite, con modifica ed eliminazione ordine
  (il magazzino viene ripristinato/riadeguato di conseguenza).
- **Tessere prepagate**: crea una tessera (codice, forza armata, grado, cognome,
  nome) e registra le ricariche in €. In cassa scansiona la tessera del cliente
  per addebitare la spesa sul suo credito. **Se il lettore è in avaria**, nel
  pannello scontrino c'è la ricerca **cliente per cognome**: digiti il cognome,
  se più tessere corrispondono le vedi tutte (con grado, nome e credito) e
  clicchi quella giusta. Modificando lo storico di una tessera si aggiornano
  automaticamente registro di cassa e magazzino. **Ogni singola** creazione di
  tessera e **ogni singola** ricarica richiede la password `Oslalepass1` in una
  finestra dedicata (non il popup del browser).
- **Statistiche**: per tipologia, prodotti più venduti, metodo di pagamento,
  top clienti, incasso ultimi 14 giorni.
- **Incasso**: oggi, ieri, ultimi 7/30 giorni, questo mese o periodo personalizzato
  (dal → al), con split contanti/carte e ricariche incassate.

I dati sono salvati automaticamente su disco in UTF-8 (senza BOM). Da Inventario
puoi anche **esportare/importare** un backup `.json`.
