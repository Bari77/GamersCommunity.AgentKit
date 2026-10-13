# Sync AgentKit lint baseline (.editorconfig, .gitattributes, C# StyleCop props) into the host repository

# Usage (from product-repo root):
#   ./AgentKit/scripts/Sync-Lint.ps1

param(
    [string] $RepoRoot = ""
)

$ErrorActionPreference = "Stop"

$agentKitRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $agentKitRoot "..")).Path
}

$source = Join-Path $agentKitRoot "lint"

if (-not (Test-Path $source)) {
    throw "AgentKit lint baseline not found at $source"
}

$files = @(".editorconfig", ".gitattributes")

if (Get-ChildItem $RepoRoot -Filter "*.sln" -File) {
    $files += @("Directory.Build.props", "stylecop.json")
}

foreach ($file in $files) {
    Copy-Item -Force (Join-Path $source $file) (Join-Path $RepoRoot $file)
    Write-Host "Synced $file"
}

Write-Host "Done: $RepoRoot"
