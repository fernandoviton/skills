# Claude Code Skills & Agents

A collection of custom skills and agents for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Contents

### Skills

- **review-plan** — Iteratively reviews a plan file using a reviewer subagent. Auto-applies critical and medium-priority feedback, consults you on low-priority items. Usage: `/review-plan [max-iterations] [plan-file-path]`

### Agents

- **plan-reviewer** — Senior engineer reviewer that verifies plan references against the actual codebase, checking for correctness, completeness, risk, sequencing, and consistency.

## Install

### Local (project-level)

Installs to `<project>/.claude/` so skills are available in that project only.

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/fernandoviton/skills/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/fernandoviton/skills/main/install.ps1 | iex
```

### Global (user-level)

Installs to `~/.claude/` so skills are available across all projects.

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/fernandoviton/skills/main/install.sh | bash -s -- -g
```

**Windows (PowerShell):**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/fernandoviton/skills/main/install.ps1))) -g
```

### From a local clone

```bash
git clone https://github.com/fernandoviton/skills.git
cd skills

# local
bash install.sh
# or global
bash install.sh -g
```
