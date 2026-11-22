@echo off
setlocal DisableDelayedExpansion
set "INVENTORY_FILE=%~f0"
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "try { $ErrorActionPreference = 'Stop'; $src = [IO.File]::ReadAllText($env:INVENTORY_FILE); $body = ($src -split '(?m)^:INVENTORY_BODY\r?$', 2)[1]; & ([scriptblock]::Create($body)); exit 0 } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }"
set "result=%errorlevel%"
echo.
pause
exit /b %result%
:INVENTORY_BODY
$Folder = [IO.Path]::GetDirectoryName($env:INVENTORY_FILE)
if ([IO.Path]::GetFileName($Folder) -ine 'inventory') {
    $Folder = [IO.Path]::Combine($Folder, 'inventory')
}
if (-not [IO.Directory]::Exists($Folder)) {
    throw "Could not find '$Folder'. Place this file inside the inventory folder or next to it."
}

$ErrorActionPreference = 'Stop'
$categories = 'Hardware', 'Services', 'Network'
$files = Get-ChildItem -LiteralPath $Folder -File -Recurse -Filter '*.md'
$entries = @(foreach ($file in $files) {
    if ($file.Name -eq 'README.md') { continue }
    $relative = $file.FullName.Substring($Folder.Length + 1).Replace('\', '/')
    $parts = $relative.Split('/')
    $category = $categories | Where-Object { $_ -eq $parts[0] } | Select-Object -First 1
    if (!$category) {
        if ($file.BaseName -notmatch '(?i)(?:^|[^a-z])(hardware|services|network)(?:$|[^a-z])') { continue }
        $category = $Matches[1]
    }
    $day = [datetime]::MinValue
    if ($file.BaseName -match '(?<!\d)\d{4}-\d{2}-\d{2}(?!\d)') {
        if (-not [datetime]::TryParseExact($Matches[0], 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, 'None', [ref]$day)) {
            throw "Invalid date in $relative"
        }
    }
    $version = [version]'0.0'
    if ($file.BaseName -match '(?i)(?:^|[^a-z])v(\d+(?:\.\d+){0,3})') {
        $number = $Matches[1]
        if (!$number.Contains('.')) { $number += '.0' }
        $version = [version]$number
    }
    $url = ($parts | ForEach-Object { [Uri]::EscapeDataString($_).Replace('(', '%28').Replace(')', '%29') }) -join '/'
    $label = $file.Name -replace '([\\\[\]\x60*_<>])', '\$1'
    [pscustomobject]@{
        Category = $category
        Preferred = ($file.BaseName -eq $category -and ($parts.Count -eq 1 -or ($parts.Count -eq 2 -and $parts[0] -eq $category)))
        Date = $day
        Version = $version
        Path = $relative
        File = $file
        Link = "[$label](./$url)"
    }
})
if (!$entries.Count) { throw "No hardware, services, or network Markdown files found in $Folder." }

$lines = @('# Inventory', '')
foreach ($category in $categories) {
    $lines += "## $category", ''
    $ordered = @($entries | Where-Object { $_.Category -eq $category } | Sort-Object @{Expression='Preferred';Descending=$true}, @{Expression='Date';Descending=$true}, @{Expression='Version';Descending=$true}, Path)
    if (!$ordered.Count) {
        $lines += 'No inventory recorded.', ''
        continue
    }
    $current = $ordered[0]
    $lines += "Current snapshot: $($current.Link)", ''
    $lines += [IO.File]::ReadAllText($current.File.FullName), ''
    if ($ordered.Count -gt 1) {
        $lines += '### Older versions', ''
        foreach ($older in ($ordered | Select-Object -Skip 1)) {
            $lines += "- $($older.Link)"
        }
        $lines += ''
    }
}
$outputPath = [IO.Path]::Combine($Folder, 'README.md')
[IO.File]::WriteAllLines($outputPath, [string[]]$lines, [Text.UTF8Encoding]::new($false))
Write-Output "Generated $outputPath from $($entries.Count) inventory files."
