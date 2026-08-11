# 🔎 codereviewer-lite

![CI](https://img.shields.io/github/actions/workflow/status/YOUR_ORG/codereviewer-lite/ci.yml?branch=main&label=CI)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Node](https://img.shields.io/badge/node-%3E%3D20-brightgreen)
![Release](https://img.shields.io/github/v/release/YOUR_ORG/codereviewer-lite?include_prereleases)

A **local, offline-first AI code review tool** — get feedback on your changes
before you open a PR, right from the terminal.

## ✨ Features

- Reviews `HEAD` vs any base branch, or just staged changes
- Built-in heuristic static checks: stray `console.log`, TODO/FIXME, possible
  hardcoded secrets, empty catch blocks, loose equality, overly long lines
- Optional AI review: set `ANTHROPIC_API_KEY` for deeper, contextual feedback
- Zero setup required to get useful output — works with no API key

## 📦 Install

```bash
git clone https://github.com/YOUR_ORG/codereviewer-lite.git
cd codereviewer-lite
bash scripts/setup.sh
npm install
```

## 🚀 Usage

Review your current branch against `main`:

```bash
node src/codereviewer.js review
```

Review against a different base branch:

```bash
node src/codereviewer.js review --base develop
```

Review only what's staged:

```bash
git add -A
node src/codereviewer.js review --staged
```

Example output:

```
🔎 codereviewer-lite — heuristic review (2 file(s), 6 added line(s))

🛑 [CRITICAL] Possible hardcoded secret/credential.
    const apiKey = "sk-abc123"
💡 [NIT] Leftover console.log — remove before merging.
    console.log("debug", user)

Total findings: 2
```

Enable AI-powered review:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
node src/codereviewer.js review
```

## 🧰 npm scripts

| Script | Description |
|---|---|
| `npm start` | Run the CLI (`src/codereviewer.js`) |
| `npm test` | Run the unit tests |
| `npm run tracker` | Show achievement badge progress |
| `npm run roadmap` | Show the Day 1 → Month 1 roadmap |

## 🏆 GitHub achievement scripts

```bash
bash scripts/unlock-all.sh
bash scripts/quickdraw.sh
bash scripts/yolo.sh
bash scripts/publicist.sh
bash scripts/pull-shark.sh 128
bash scripts/pair-extraordinaire.sh "Linus Torvalds" "linus@example.com"
```

All scripts require [`gh`](https://cli.github.com/) authenticated (`gh auth login`) and auto-detect your repo.

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

[MIT](LICENSE)
