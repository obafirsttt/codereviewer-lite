# Contributing to codereviewer-lite

Thanks for your interest in improving codereviewer-lite! This project welcomes issues, feature requests, and pull requests.

## Getting Started

```bash
git clone https://github.com/<your-org>/codereviewer-lite.git
cd codereviewer-lite
bash scripts/setup.sh
npm install
npm test
```

## Development workflow

1. Fork the repo and create a branch off `main`:
   ```bash
   git checkout -b feature/my-change
   ```
2. Make your changes, add tests where relevant.
3. Run the test suite:
   ```bash
   npm test
   ```
4. Commit using clear, descriptive messages (tip: this repo's sibling project `autocommit` can help!).
5. Push your branch and open a Pull Request against `main`. The PR template will guide you.

## Code style

- Plain, dependency-light Node.js (CommonJS or ESM as used in `src/`).
- Keep functions small and covered by a test where practical.
- Run `npm test` before pushing — CI will run it again on every push/PR.

## Reporting bugs / requesting features

Please use the provided GitHub issue templates:

- 🐛 [Bug report](.github/ISSUE_TEMPLATE/bug_report.md)
- ✨ [Feature request](.github/ISSUE_TEMPLATE/feature_request.md)

## Helper scripts

This repo ships a set of `gh`-powered helper scripts under `scripts/` to make working with GitHub faster:

| Script | Purpose |
|---|---|
| `scripts/setup.sh` | Checks dependencies and makes all scripts executable |
| `scripts/quickdraw.sh` | Opens and closes a GitHub issue quickly |
| `scripts/yolo.sh` | Creates a branch, opens a PR, merges it |
| `scripts/publicist.sh` | Cuts a `v1.0.0` GitHub Release |
| `scripts/pull-shark.sh` | Opens/merges N PRs (2/16/128 = Bronze/Silver/Gold) |
| `scripts/pair-extraordinaire.sh` | Creates a co-authored PR and merges it |
| `scripts/unlock-all.sh` | Interactive menu to run any/all of the above |

All scripts require the [GitHub CLI](https://cli.github.com/) (`gh`) to be installed and authenticated (`gh auth login`).

## Code of Conduct

Be kind, be constructive, assume good intent. Harassment or abuse of any kind will not be tolerated.
