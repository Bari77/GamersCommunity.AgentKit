# Sync AgentKit Cursor rules into the host repository

# Usage (from product-repo root):
#   ./AgentKit/scripts/Sync-CursorRules.ps1

param(
    [string] $RepoRoot = ""
)

$ErrorActionPreference = "Stop"

$agentKitRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $agentKitRoot "..")).Path
}

$source = Join-Path $agentKitRoot "cursor\rules"
$target = Join-Path $RepoRoot ".cursor\rules"

if (-not (Test-Path $source)) {
    throw "AgentKit rules not found at $source"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null

Get-ChildItem $source -Filter "*.mdc" | ForEach-Object {
    Copy-Item -Force $_.FullName (Join-Path $target $_.Name)
    Write-Host "Synced $($_.Name)"
}

Write-Host "Done → $target"
