param(
    [Parameter(Mandatory = $true)]
    [string]$AsmFolder,

    [Parameter(Mandatory = $true)]
    [string]$HexFolder
)

$tasm = Join-Path $PSScriptRoot "tasm.exe"

if (!(Test-Path $tasm)) {
    Write-Host "ERROR: tasm.exe not found!" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $AsmFolder)) {
    Write-Host "ERROR: Assembly folder not found!" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $HexFolder)) {
    New-Item -ItemType Directory -Path $HexFolder | Out-Null
}

$success = 0
$failed = 0

$asmFiles = Get-ChildItem -Path $AsmFolder -Filter *.asm

foreach ($file in $asmFiles) {
    $asmRelative = Join-Path $AsmFolder $file.Name
    $hexRelative = Join-Path $HexFolder ($file.BaseName + ".hex")

    & $tasm $asmRelative $hexRelative

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] $($file.Name)" -ForegroundColor Green
        $success++

        if (Test-Path $hexRelative) {
            try {
                $lineCount = (Get-Content -Path $hexRelative | Measure-Object -Line).Lines
                
                if ($lineCount -gt 16) {
                    Write-Host "Warning! $($file.BaseName).hex has $lineCount lines" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Warning: Could not read line count for $($file.BaseName).hex" -ForegroundColor DarkYellow
            }
        }
    }
    else {
        Write-Host "[FAILED] $($file.Name)" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "Done" -ForegroundColor Cyan
Write-Host ("Successful : {0}" -f $success) -ForegroundColor Green
Write-Host ("Failed     : {0}" -f $failed) -ForegroundColor Red