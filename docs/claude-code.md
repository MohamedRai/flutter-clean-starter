# Claude Code setup

The repository is configured so that Claude Code follows the same rules as
the team.

| Piece | Location | Role |
|---|---|---|
| `CLAUDE.md` | root | Always-loaded rules: architecture, standards, commands, definition of done, project context |
| Skills | `.claude/skills/<name>/SKILL.md` | Step-by-step playbooks loaded when a task matches |
| Agents | `.claude/agents/<name>.md` | Specialized sub-agents with restricted tools |
| Settings | `.claude/settings.json` | Pre-approved commands, denied paths, hooks |
| Format hook | `tool/claude/format_hook.dart` | Runs `dart format` after every edit |

## CLAUDE.md

Kept short (< 300 lines) and rule-focused; details are linked from
`docs/`. The **Project-Specific Context** section at the bottom is where
you describe the app built on the starter (purpose, glossary, backend,
features, business rules). Fill it in early — it is the most valuable
context Claude gets.

## Skills

| Skill | Use when |
|---|---|
| `create-feature` | a new feature/module is needed |
| `add-usecase` | a new action in an existing feature |
| `add-api-endpoint` | integrating a backend route end-to-end |
| `add-screen` | a new page in an existing feature |
| `write-tests` | tests are missing or coverage is low |
| `add-localization` | any new UI text or language |
| `refactor-to-clean-architecture` | moving messy code into layers |
| `quality-check` | before finishing a task or opening a PR |
| `add-flavor-config` | a new per-environment value |

Claude picks a skill from its `description`; you can also invoke one
directly, e.g. `/create-feature orders`. Skills always prefer the mason
bricks and end with the definition-of-done checks.

## Agents

| Agent | Tools | Purpose |
|---|---|---|
| `flutter-architect` | read-only | Layer/SOLID violations report |
| `code-reviewer` | read + git/analyze | Diff review: correctness, security, perf |
| `test-engineer` | edit | Write/fix tests, reach coverage |
| `ui-builder` | edit | Theme-compliant, accessible, RTL-safe UI |
| `bug-hunter` | edit | Failing test first, then root-cause fix |
| `performance-auditor` | read + edit | Rebuilds, const, lists, images |
| `docs-writer` | edit | Keep README/docs/dartdoc in sync |

Ask for them by name: "use the code-reviewer agent on my changes".

## Settings and hooks

`.claude/settings.json`:

- **permissions.allow** — routine, safe commands run without a prompt
  (`flutter analyze`, `flutter test`, `dart format`, `build_runner build`,
  `mason make`, read-only git). Anything else still asks.
- **permissions.deny** — Claude cannot read the real `env/*.json` files.
- **PostToolUse hook** — after `Edit`/`MultiEdit`/`Write`, runs
  `dart "$CLAUDE_PROJECT_DIR/tool/claude/format_hook.dart"`, which formats
  the edited `.dart` file (generated files and brick templates are
  skipped). It never blocks the edit.

### OS notes

The hook is written in Dart (not bash/jq) so it behaves the same on
Windows, macOS and Linux — Dart is always available in a Flutter project.
On Windows, Claude Code runs hook commands through Git Bash, which expands
`$CLAUDE_PROJECT_DIR`. The first run per session compiles the script
(~1–2 s).

Personal overrides (extra permissions, your own hooks) go in
`.claude/settings.local.json`, which is not committed.

## Extending

**New skill**: create `.claude/skills/<name>/SKILL.md`:

```markdown
---
name: <name>
description: What it does and, crucially, WHEN to use it (trigger phrases).
---

# Title
Numbered steps. Reference bricks, files and the definition of done.
```

**New agent**: create `.claude/agents/<name>.md`:

```markdown
---
name: <name>
description: When Claude should delegate to this agent.
tools: Read, Grep, Glob          # only what it needs
---

System prompt: role, rules, workflow, output format.
```

Keep both short and specific; link to `docs/` instead of repeating it.
Update `CLAUDE.md` §11 and this page when you add one.
