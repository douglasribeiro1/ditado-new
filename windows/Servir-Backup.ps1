# Serve o arquivo de backup uma única vez em http://127.0.0.1:PORTA/backup.json
# para o site importar automaticamente. Fecha sozinho após servir ou após o tempo limite.
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [int]$Port = 47831,
  [int]$TimeoutSec = 90
)

if (-not (Test-Path -LiteralPath $Path)) { exit 1 }
$bytes = [System.IO.File]::ReadAllBytes($Path)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
try { $listener.Start() } catch { exit 1 }

$deadline = (Get-Date).AddSeconds($TimeoutSec)
$served = $false
try {
  while (-not $served -and (Get-Date) -lt $deadline) {
    $task = $listener.GetContextAsync()
    while (-not $task.AsyncWaitHandle.WaitOne(500)) {
      if ((Get-Date) -ge $deadline) { break }
    }
    if (-not $task.IsCompleted) { break }
    $ctx = $task.Result
    $res = $ctx.Response
    $res.Headers.Add('Access-Control-Allow-Origin', '*')
    $res.Headers.Add('Access-Control-Allow-Private-Network', 'true')
    $res.Headers.Add('Access-Control-Allow-Headers', '*')
    if ($ctx.Request.HttpMethod -eq 'OPTIONS') {
      $res.StatusCode = 204
    } else {
      $res.ContentType = 'application/json; charset=utf-8'
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
      $served = $true
    }
    $res.Close()
  }
} finally {
  $listener.Stop()
}
