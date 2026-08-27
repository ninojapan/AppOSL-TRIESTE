# =====================================================================
#  Gestione O.S.L. Nave TRIESTE - Server HTTP locale in PowerShell puro
#  Nessuna dipendenza esterna: solo PowerShell integrato di Windows.
#  Stessa meccanica di avvio del progetto GEPA MASTER.
# =====================================================================

$ErrorActionPreference = "Stop"

# ------------------------- Configurazione ----------------------------
$Port      = 5030
$AppName   = "OSL TRIESTE"          # base nome file dati
$HtmlFile  = "OSL TRIESTE.html"     # file principale della SPA

# Cartella dello script (tutto e' relativo a questa cartella -> portabile)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($ScriptDir)) { $ScriptDir = (Get-Location).Path }

$DataFile   = Join-Path $ScriptDir "$AppName.json"
$LocalFile  = Join-Path $ScriptDir "$AppName local.json"
$BackupFile = "$DataFile.backup"

# UTF-8 SENZA BOM ovunque
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Strutture JSON di default
$DefaultData = @'
{
  "products": [],
  "sales": [],
  "cards": [],
  "settings": { "currency": "EUR", "storeName": "O.S.L. Nave TRIESTE" }
}
'@

$DefaultLocal = @'
{
  "cart": [],
  "lastUpdate": ""
}
'@

# Tabella MIME types
$MimeTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".htm"  = "text/html; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif"  = "image/gif"
  ".svg"  = "image/svg+xml"
  ".ico"  = "image/x-icon"
}

# --------------------------- Funzioni --------------------------------

function Read-TextFileUtf8($path) {
  if (Test-Path $path) {
    $content = [System.IO.File]::ReadAllText($path, $Utf8NoBom)
    # rimuovi eventuale BOM residuo (U+FEFF) e fai trim
    $content = $content.TrimStart([char]0xFEFF)
    return $content.Trim()
  }
  return ""
}

function Write-TextFileUtf8($path, $text) {
  [System.IO.File]::WriteAllText($path, $text, $Utf8NoBom)
}

function Get-RequestBody($request) {
  $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
  $body = $reader.ReadToEnd()
  $reader.Close()
  return $body
}

function Send-ByteResponse($response, $bytes, $contentType, $status = 200) {
  $response.StatusCode = $status
  $response.ContentType = $contentType
  $response.ContentLength64 = $bytes.Length
  $response.OutputStream.Write($bytes, 0, $bytes.Length)
  $response.OutputStream.Close()
}

function Send-JsonResponse($response, $json, $status = 200) {
  $bytes = $Utf8NoBom.GetBytes($json)
  Send-ByteResponse $response $bytes "application/json; charset=utf-8" $status
}

function Send-StaticFile($response, $path) {
  if ($path -eq "/" -or [string]::IsNullOrWhiteSpace($path)) {
    $path = "/$HtmlFile"
  }
  $relative = [System.Uri]::UnescapeDataString($path.TrimStart("/"))
  $fullPath = Join-Path $ScriptDir $relative

  # fallback al file HTML principale per path non trovati (comportamento SPA)
  if (-not (Test-Path $fullPath -PathType Leaf)) {
    $fullPath = Join-Path $ScriptDir $HtmlFile
  }

  if (Test-Path $fullPath -PathType Leaf) {
    $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
    $ct  = $MimeTypes[$ext]
    if (-not $ct) { $ct = "application/octet-stream" }
    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    Send-ByteResponse $response $bytes $ct 200
  }
  else {
    $bytes = $Utf8NoBom.GetBytes("404 - File non trovato")
    Send-ByteResponse $response $bytes "text/plain; charset=utf-8" 404
  }
}

# --------------------------- Avvio server ----------------------------

$http   = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$http.Prefixes.Add($prefix)

try {
  $http.Start()
}
catch {
  Write-Host "ERRORE: impossibile avviare il server sulla porta $Port" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  Write-Host ""
  Write-Host "Suggerimento: la porta potrebbe essere gia' in uso. Chiudi altre istanze e riprova." -ForegroundColor Yellow
  Write-Host "Premi INVIO per chiudere..."
  Read-Host | Out-Null
  exit 1
}

# ---------------------------- Banner ---------------------------------
Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Gestione O.S.L. Nave TRIESTE - Server locale"   -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "   App:          " -NoNewline; Write-Host "http://localhost:$Port" -ForegroundColor Green
Write-Host "   File dati:    $DataFile"   -ForegroundColor Gray
Write-Host "   File locale:  $LocalFile"  -ForegroundColor Gray
Write-Host ""
Write-Host "   Per FERMARE il server: premi " -NoNewline; Write-Host "CTRL+C" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------- Loop richieste ----------------------------
try {
  while ($http.IsListening) {
    $response = $null
    try {
      $context  = $http.GetContext()
      $request  = $context.Request
      $response = $context.Response

      # Header CORS su OGNI risposta
      $response.Headers.Add("Access-Control-Allow-Origin",  "*")
      $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, DELETE, PUT, OPTIONS")
      $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")

      # Preflight OPTIONS
      if ($request.HttpMethod -eq "OPTIONS") {
        $response.StatusCode = 200
        $response.Close()
        continue
      }

      $path   = $request.Url.AbsolutePath
      $method = $request.HttpMethod

      # ------------------------- ROUTING API -------------------------
      if ($path -eq "/api/entries" -and $method -eq "GET") {
        $data = Read-TextFileUtf8 $DataFile
        if ([string]::IsNullOrWhiteSpace($data)) { $data = $DefaultData }
        Send-JsonResponse $response $data
      }
      elseif ($path -eq "/api/entries" -and $method -eq "POST") {
        $body = Get-RequestBody $request
        # backup PRIMA di sovrascrivere il file dati principale
        if (Test-Path $DataFile) { Copy-Item $DataFile $BackupFile -Force }
        Write-TextFileUtf8 $DataFile $body
        Send-JsonResponse $response '{"status":"ok"}'
      }
      elseif ($path -eq "/api/local-data" -and $method -eq "GET") {
        $data = Read-TextFileUtf8 $LocalFile
        if ([string]::IsNullOrWhiteSpace($data)) { $data = $DefaultLocal }
        Send-JsonResponse $response $data
      }
      elseif ($path -eq "/api/local-data" -and $method -eq "POST") {
        # salvataggio veloce, nessun backup
        $body = Get-RequestBody $request
        Write-TextFileUtf8 $LocalFile $body
        Send-JsonResponse $response '{"status":"ok"}'
      }
      else {
        # ----------------------- File statici ------------------------
        Send-StaticFile $response $path
      }
    }
    catch {
      # Un errore su UNA richiesta non deve uccidere il server
      Write-Host ("Errore richiesta: " + $_.Exception.Message) -ForegroundColor Yellow
      if ($response -ne $null) {
        try {
          $response.StatusCode = 500
          $response.Close()
        } catch { }
      }
    }
  }
}
finally {
  if ($http.IsListening) { $http.Stop() }
  $http.Close()
  Write-Host ""
  Write-Host "Server fermato" -ForegroundColor Yellow
}
