# Contributing

Thanks for helping make this starter better for Flutter developers.

## Ways to help

- **Report a bug** — open an issue with steps to reproduce, the flavor,
  platform, `flutter --version`, and logs.
- **Suggest an improvement** — open an issue first for anything larger than
  a small fix, so we can agree on the approach.
- **Improve the docs** — typos, unclear steps, missing examples.
- **Add or improve a mason brick** — generated code must pass
  `flutter analyze` and its own tests (see
  [docs/mason-bricks.md](docs/mason-bricks.md)).

## Development setup

```sh
git clone https://github.com/MohamedRai/flutter-clean-starter.git
cd flutter-clean-starter
make setup            # Windows: ./scripts/setup.ps1
make run-dev          # Windows: ./scripts/run-dev.ps1
```

Requirements: Flutter 3.47.x (stable). See the
[README](README.md#prerequisites).

## Pull requests

1. Fork the repo and branch from `main` (`feat/orders-brick`,
   `fix/retry-interceptor`).
2. Follow the rules in [CLAUDE.md](CLAUDE.md) (architecture, coding
   standards, testing) — they apply to humans too.
3. Add or update tests; keep `domain` + `data` coverage ≥ 80 %.
4. Update the docs when behavior or structure changes.
5. Run the checks locally — CI runs the same ones:

   ```sh
   make format analyze coverage   # Windows: scripts/format.ps1, analyze.ps1, coverage.ps1
   ```

6. Use [Conventional Commits](https://www.conventionalcommits.org/) for
   commit messages and the PR title: `feat(core): …`, `fix(bricks): …`,
   `docs: …`, `test: …`, `refactor: …`, `chore: …`.
7. Keep pull requests focused: one topic per PR.

## Ground rules

- `lib/core` stays feature-agnostic; `domain` stays pure Dart.
- No secrets in the repository — env files are git-ignored; only
  `env/*.example.json` templates are committed.
- Be respectful and constructive in issues and reviews.

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
