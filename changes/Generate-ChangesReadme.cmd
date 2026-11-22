@echo off
setlocal DisableDelayedExpansion
set "CHANGE_INDEX_FILE=%~f0"
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "try { $ErrorActionPreference = 'Stop'; $src = [IO.File]::ReadAllText($env:CHANGE_INDEX_FILE); $body = ($src -split '(?m)^:CHANGE_INDEX_BODY\r?$', 2)[1]; & ([scriptblock]::Create($body)); exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
set "result=%errorlevel%"
echo.
pause
exit /b %result%
:CHANGE_INDEX_BODY
$Folder = [IO.Path]::GetDirectoryName($env:CHANGE_INDEX_FILE)
if ([IO.Path]::GetFileName($Folder) -ine 'changes') {
    $Folder = [IO.Path]::Combine($Folder, 'changes')
}
if (-not [IO.Directory]::Exists($Folder)) {
    throw "Could not find '$Folder'. Place this file inside the changes folder or next to it."
}

$ErrorActionPreference = 'Stop'
$culture = [Globalization.CultureInfo]::InvariantCulture
$rows = @(foreach ($file in Get-ChildItem -LiteralPath $Folder -File -Filter '*.md' | Sort-Object Name) {
    if ($file.Name -eq 'README.md') { continue }
    if ($file.BaseName -notmatch '^(\d{4}-\d{2}-\d{2})-(.+)$') {
        Write-Warning "Skipping $($file.Name): expected YYYY-MM-DD-description.md"
        continue
    }
    $stamp = $Matches[1]
    $title = $Matches[2].Replace('-', ' ')
    $day = [datetime]::MinValue
    if (-not [datetime]::TryParseExact($stamp, 'yyyy-MM-dd', $culture, 'None', [ref]$day)) {
        Write-Warning "Skipping $($file.Name): invalid date"
        continue
    }
    [pscustomobject]@{
        Date = $day
        Name = $file.Name
        Heading = "## $stamp - $title"
        Body = [IO.File]::ReadAllText($file.FullName, [Text.Encoding]::UTF8)
    }
})
$lines = @('# Change history', '')
if ($rows.Count) {
    $lines += $rows | Sort-Object @{Expression='Date'; Descending=$true}, Name | ForEach-Object {
        $_.Heading
        ''
        $_.Body
        ''
    }
} else {
    $lines += 'No dated change notes yet.'
}
$outputPath = Join-Path (Get-Item -LiteralPath $Folder).FullName 'README.md'
[IO.File]::WriteAllLines($outputPath, [string[]]$lines, [Text.UTF8Encoding]::new($false))
Write-Output "Generated $outputPath with $($rows.Count) entries."
