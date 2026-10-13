# Architecture Decision Records

Short records of significant decisions: context, decision, consequences.
Never rewrite an accepted ADR — add a new one that supersedes it.

| # | Decision | Status |
|---|---|---|
| [0001](0001-state-management-bloc.md) | Bloc/Cubit with sealed Equatable states | Accepted |
| [0002](0002-dependency-injection-injectable.md) | get_it + injectable; annotation-free domain and core | Accepted |
| [0003](0003-routing-go-router.md) | go_router with typed routes; navigation via callbacks | Accepted |
| [0004](0004-result-type.md) | Own sealed `Result<T>` instead of dartz/fpdart `Either` | Accepted |
| [0005](0005-environment-configuration.md) | `--dart-define-from-file` env files instead of envied | Accepted |

Template:

```markdown
# NNNN. Title
- Status: Proposed | Accepted | Superseded by NNNN
- Date: YYYY-MM-DD

## Context
## Decision
## Consequences
```
