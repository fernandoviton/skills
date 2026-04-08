#Requires -Version 5.1
<#!
.SYNOPSIS
    Install skills and agents from github.com/fernandoviton/skills
.PARAMETER Global
    Install globally to ~/.claude/ (user-level, all projects)
.PARAMETER Target
    Target project directory (default: current directory)
.EXAMPLE
    .\install.ps1
    .\install.ps1 -g
    irm https://raw.githubusercontent.com/fernandoviton/skills/main/install.ps1 | iex
#>
[CmdletBinding()]
param(
    [Alias('g')]
    [switch]$Global,

    [Parameter(Position = 0)]
    [string]$Target = '.'
)

$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/fernandoviton/skills.git'

if ($Global) {
    $DestDir = Join-Path $HOME '.claude'
} else {
    if (-not (Test-Path -LiteralPath $Target)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
    }
    $DestDir = Join-Path (Resolve-Path -LiteralPath $Target).Path '.claude'
}

if (-not (Test-Path $DestDir)) {
    Write-Host "Creating $DestDir"
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
}

# Clone to a temporary directory.
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-install-" + [guid]::NewGuid().ToString('N').Substring(0, 8))

try {
    git clone --depth 1 --quiet $RepoUrl $TmpDir
    if ($LASTEXITCODE -ne 0) {
        throw 'git clone failed'
    }

    # Copy skills
    $SkillsSrc = Join-Path $TmpDir 'skills'
    if (Test-Path $SkillsSrc) {
        $SkillsDest = Join-Path $DestDir 'skills'
        if (-not (Test-Path $SkillsDest)) {
            New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null
        }

        Copy-Item "$SkillsSrc\*" $SkillsDest -Recurse -Force
        Write-Host 'Installed skills:'
        Get-ChildItem $SkillsDest -Recurse -Filter 'SKILL.md' | ForEach-Object {
            $match = Select-String -Path $_.FullName -Pattern '^name:' | Select-Object -First 1
            if ($match) {
                $name = $match.Line -replace '^name:\s*', ''
                Write-Host "  - $name"
            }
        }
    }

    # Copy agents
    $AgentsSrc = Join-Path $TmpDir 'agents'
    if (Test-Path $AgentsSrc) {
        $AgentsDest = Join-Path $DestDir 'agents'
        if (-not (Test-Path $AgentsDest)) {
            New-Item -ItemType Directory -Path $AgentsDest -Force | Out-Null
        }

        Copy-Item "$AgentsSrc\*" $AgentsDest -Recurse -Force
        Write-Host 'Installed agents:'
        Get-ChildItem $AgentsDest -File | ForEach-Object {
            Write-Host "  - $($_.Name)"
        }
    }

    Write-Host ''
    Write-Host "Done! Skills installed to $DestDir\"
} finally {
    if (Test-Path $TmpDir) {
        Remove-Item $TmpDir -Recurse -Force
    }
}
