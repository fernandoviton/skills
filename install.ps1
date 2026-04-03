# Install skills and agents from github.com/fernandoviton/skills
# Usage: irm https://raw.githubusercontent.com/fernandoviton/skills/main/install.ps1 | iex
#   or:  .\install.ps1 [target-dir]

param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/fernandoviton/skills.git"

# Resolve to absolute path
$Target = (Resolve-Path $Target).Path

$ClaudeDir = Join-Path $Target ".claude"

if (-not (Test-Path $ClaudeDir)) {
    Write-Host "No .claude/ directory found in $Target -- creating one."
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

# Clone to a temp dir
$TmpDir = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    $SrcDir = Join-Path $TmpDir "skills-repo"
    git clone --depth 1 --quiet $RepoUrl $SrcDir

    # Copy skills
    $SrcSkills = Join-Path $SrcDir "skills"
    if (Test-Path $SrcSkills) {
        $SkillsDest = Join-Path $ClaudeDir "skills"
        New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null
        Copy-Item (Join-Path $SrcSkills "*") $SkillsDest -Recurse -Force
        Write-Host "Installed skills:"
        Get-ChildItem -Path $SkillsDest -Recurse -Filter "SKILL.md" | ForEach-Object {
            $match = Select-String -Path $_.FullName -Pattern '^name:' | Select-Object -First 1
            if ($match) {
                $nameLine = $match.Line -replace '^name:\s*', ''
                Write-Host "  - $nameLine"
            }
        }
    }

    # Copy agents
    $SrcAgents = Join-Path $SrcDir "agents"
    if (Test-Path $SrcAgents) {
        $AgentsDest = Join-Path $ClaudeDir "agents"
        New-Item -ItemType Directory -Path $AgentsDest -Force | Out-Null
        Copy-Item (Join-Path $SrcAgents "*") $AgentsDest -Recurse -Force
        Write-Host "Installed agents:"
        Get-ChildItem -Path $AgentsDest | ForEach-Object {
            Write-Host "  - $($_.Name)"
        }
    }
} finally {
    Remove-Item -Recurse -Force $TmpDir
}

Write-Host ""
Write-Host "Done! Skills installed to $ClaudeDir"
