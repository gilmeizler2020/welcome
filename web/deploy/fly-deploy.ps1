# Deploy Fly.io — Windows (PowerShell)
# Uso: .\deploy\fly-deploy.ps1

$ErrorActionPreference = "Stop"
$AppName = if ($env:FLY_APP_NAME) { $env:FLY_APP_NAME } else { "welcome-locaweb" }
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$fly = Get-Command flyctl -ErrorAction SilentlyContinue
if (-not $fly) { $fly = Get-Command fly -ErrorAction SilentlyContinue }
if (-not $fly) {
    Write-Host "ERRO: Instale flyctl: https://fly.io/docs/flyctl/install/" -ForegroundColor Red
    exit 1
}

Write-Host "==> Deploy $AppName" -ForegroundColor Cyan
Write-Host "    URL: https://${AppName}.fly.dev/"

foreach ($f in @("fly.toml", "Dockerfile", "public\index.php", "config.fly.php")) {
    if (-not (Test-Path $f)) {
        Write-Host "ERRO: $f nao encontrado" -ForegroundColor Red
        exit 1
    }
}

& $fly.Source deploy -a $AppName --ha=false

Write-Host ""
Write-Host "Deploy OK!" -ForegroundColor Green
Write-Host "Login:  https://${AppName}.fly.dev/"
Write-Host "Painel: https://${AppName}.fly.dev/panel/login.php"
