@echo off
setlocal DisableDelayedExpansion
set "KB_INDEX_FILE=%~f0"
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "try { $ErrorActionPreference = 'Stop'; $src = [IO.File]::ReadAllText($env:KB_INDEX_FILE); $body = ($src -split '(?m)^:KB_INDEX_BODY\r?$', 2)[1]; & ([scriptblock]::Create($body)); exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
set "result=%errorlevel%"
echo.
pause
exit /b %result%
:KB_INDEX_BODY
$Folder = [IO.Path]::GetDirectoryName($env:KB_INDEX_FILE)
if ([IO.Path]::GetFileName($Folder) -ine 'knowledge-base') {
    $Folder = [IO.Path]::Combine($Folder, 'knowledge-base')
}
if (-not [IO.Directory]::Exists($Folder)) {
    throw "Could not find '$Folder'. Place this file inside the knowledge-base folder or next to it."
}

$ErrorActionPreference = 'Stop'
$entries = @(foreach ($file in Get-ChildItem -LiteralPath $Folder -File -Filter '*.md') {
    if ($file.Name -eq 'README.md') { continue }
    $reader = [IO.File]::OpenText($file.FullName)
    try { $firstLine = [string]$reader.ReadLine() }
    finally { $reader.Dispose() }

    $title = $firstLine.Trim()
    if ($title -match '^#{1,6}(?:\s+|$)') {
        $title = ($title -replace '^#{1,6}\s*', '') -replace '\s+#+$', ''
    }
    if ([string]::IsNullOrWhiteSpace($title)) { $title = $file.BaseName }
    $label = $title -replace '([\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x7e])', '\$1'
    $url = [Uri]::EscapeDataString($file.Name).Replace('(', '%28').Replace(')', '%29')
    [pscustomobject]@{ Title = $title; Name = $file.Name; Link = "- [$label](./$url)" }
})
$lines = @('# Knowledge Base', '')
if ($entries.Count) {
    $lines += $entries | Sort-Object Title, Name | ForEach-Object { $_.Link }
} else {
    $lines += 'No articles yet.'
}
$outputPath = [IO.Path]::Combine($Folder, 'README.md')
[IO.File]::WriteAllLines($outputPath, [string[]]$lines, [Text.UTF8Encoding]::new($false))
Write-Output "Generated $outputPath with $($entries.Count) links."
