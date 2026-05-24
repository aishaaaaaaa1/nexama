# Libère de l'espace et génère Prisma sans npx (évite ENOSPC sur le cache npm).
$ErrorActionPreference = 'SilentlyContinue'

Write-Host '=== Espace disque C: ===' -ForegroundColor Cyan
$vol = Get-Volume -DriveLetter C
$freeGb = [math]::Round($vol.SizeRemaining / 1GB, 2)
Write-Host "Libre: $freeGb Go"
if ($vol.SizeRemaining -lt 500MB) {
  Write-Host 'ATTENTION: moins de 500 Mo libres — libérez de l espace avant de continuer.' -ForegroundColor Red
}

Write-Host "`n=== Nettoyage cache npm (npx / prisma echoue) ===" -ForegroundColor Cyan
npm cache clean --force
Remove-Item "$env:LOCALAPPDATA\npm-cache\_npx" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Cache npx supprime (si present).'

$backend = Split-Path $PSScriptRoot -Parent
Set-Location $backend

if (-not (Test-Path 'node_modules\prisma')) {
  Write-Host "`n=== npm install (Prisma local) ===" -ForegroundColor Cyan
  npm install
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "`n=== prisma generate (binaire local) ===" -ForegroundColor Cyan
node .\node_modules\prisma\build\index.js generate
exit $LASTEXITCODE
