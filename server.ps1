$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8000/')
$listener.Start()

Write-Host "✅ Сервер запущен: http://localhost:8000"
Write-Host "📁 Обслуживаемая папка: $PWD"
Write-Host "⏹️  Для остановки нажмите Ctrl+C"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $filePath = Join-Path $PWD.Path ($request.Url.LocalPath.TrimStart('/'))
        if ($filePath -eq $PWD.Path) { $filePath = Join-Path $PWD.Path "index.html" }
        
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllText($filePath)
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found")
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}