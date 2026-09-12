param([int]$Port = 8000)
$root = (Get-Location).Path
$prefix = "http://127.0.0.1:$Port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try { $listener.Start() } catch { Write-Host "Could not start server on port $Port. It may already be in use."; Write-Host $_; Read-Host "Press Enter to close"; exit 1 }
Write-Host "RM Enterprises server running at $prefix"
Write-Host "Keep this window open. Press Ctrl+C to stop."
$mime = @{
 '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.js'='application/javascript; charset=utf-8';
 '.json'='application/json; charset=utf-8'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.gif'='image/gif'; '.svg'='image/svg+xml';
 '.ico'='image/x-icon'; '.txt'='text/plain; charset=utf-8'; '.pdf'='application/pdf'; '.webp'='image/webp'
}
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    if ($path -eq '/') { $path = '/index.html' }
    $relative = $path.TrimStart('/').Replace('/','\\')
    if ($relative -match '\.\.') { $ctx.Response.StatusCode=400; $ctx.Response.Close(); continue }
    $file = Join-Path $root $relative
    if (Test-Path $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
      $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.StatusCode = 200
      $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
    } else {
      $msg = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
      $ctx.Response.StatusCode=404; $ctx.Response.ContentType='text/plain; charset=utf-8'; $ctx.Response.ContentLength64=$msg.Length
      $ctx.Response.OutputStream.Write($msg,0,$msg.Length)
    }
    $ctx.Response.OutputStream.Close()
  } catch { }
}
