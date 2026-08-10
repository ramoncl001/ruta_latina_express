# Skill Registry — agency

Generated: 2026-08-09  
Project: Ruta Latina Express (`agency`)

## Available Skills

| Skill | Trigger | Path |
|---|---|---|
| `sdd-init` | `sdd init`, `iniciar sdd`, `openspec init` | `~/.config/opencode/skills/sdd-init/SKILL.md` |
| `sdd-propose` | Propose a change, new feature request | `~/.config/opencode/skills/sdd-propose/SKILL.md` |
| `sdd-explore` | Explore ideas, clarify requirements | `~/.config/opencode/skills/sdd-explore/SKILL.md` |
| `sdd-spec` | Write delta specs, requirements, scenarios | `~/.config/opencode/skills/sdd-spec/SKILL.md` |
| `sdd-design` | Technical design and architecture | `~/.config/opencode/skills/sdd-design/SKILL.md` |
| `sdd-tasks` | Break change into implementation tasks | `~/.config/opencode/skills/sdd-tasks/SKILL.md` |
| `sdd-apply` | Implement tasks from specs | `~/.config/opencode/skills/sdd-apply/SKILL.md` |
| `sdd-verify` | Verify implementation vs specs | `~/.config/opencode/skills/sdd-verify/SKILL.md` |
| `sdd-archive` | Archive completed change | `~/.config/opencode/skills/sdd-archive/SKILL.md` |
| `tdd-scaffold` | Feature implementation, coding tasks | `~/.config/opencode/skills/tdd-scaffold/SKILL.md` |
| `branch-pr` | Creating PRs for review | `~/.config/opencode/skills/branch-pr/SKILL.md` |
| `work-unit-commits` | Commit splitting, reviewable units | `~/.config/opencode/skills/work-unit-commits/SKILL.md` |
| `cognitive-doc-design` | Writing guides, READMEs, RFCs | `~/.config/opencode/skills/cognitive-doc-design/SKILL.md` |
| `judgment-day` | Adversarial review, dual review | `~/.config/opencode/skills/judgment-day/SKILL.md` |

## SDD Workflow

```
propose → explore → spec → design → tasks → apply → verify → archive
```

## Notes

- No test runner: `sdd-verify` and `tdd-scaffold` will operate in lint/build-only mode
- Hybrid persistence: changes tracked in both `openspec/changes/` and Engram
