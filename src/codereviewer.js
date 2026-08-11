#!/usr/bin/env node
/**
 * codereviewer-lite — a local AI code review tool that gives feedback on your
 * changes before you submit a PR.
 *
 * Works offline with a heuristic static-analysis pass, or with a real LLM
 * review if you set ANTHROPIC_API_KEY.
 *
 * Usage:
 *   node src/codereviewer.js review                 # diff against origin/main
 *   node src/codereviewer.js review --base develop   # diff against another base
 *   node src/codereviewer.js review --staged         # review staged changes only
 */

const { execSync } = require('child_process');

function sh(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8' });
  } catch (e) {
    return '';
  }
}

function getDiff({ base, staged }) {
  if (staged) return sh('git diff --staged --unified=3 --no-color');
  const target = base || 'main';
  let diff = sh(`git diff ${target}...HEAD --unified=3 --no-color`);
  if (!diff.trim()) diff = sh(`git diff ${target} --unified=3 --no-color`);
  return diff;
}

/** Heuristic offline review: simple static checks over the diff's added lines. */
function heuristicReview(diff) {
  const addedLines = diff
    .split('\n')
    .filter((l) => l.startsWith('+') && !l.startsWith('+++'))
    .map((l) => l.slice(1));

  const findings = [];

  addedLines.forEach((line, i) => {
    const trimmed = line.trim();
    if (/console\.log\(/.test(trimmed)) {
      findings.push({ severity: 'nit', msg: 'Leftover console.log — remove before merging.', line: trimmed });
    }
    if (/TODO|FIXME/.test(trimmed)) {
      findings.push({ severity: 'info', msg: 'TODO/FIXME left in code — track it in an issue if it matters.', line: trimmed });
    }
    if (/password\s*=\s*['"]/.test(trimmed) || /api[_-]?key\s*=\s*['"]/i.test(trimmed)) {
      findings.push({ severity: 'critical', msg: 'Possible hardcoded secret/credential.', line: trimmed });
    }
    if (/catch\s*\([^)]*\)\s*{\s*}/.test(trimmed)) {
      findings.push({ severity: 'warning', msg: 'Empty catch block swallows errors silently.', line: trimmed });
    }
    if (trimmed.length > 120) {
      findings.push({ severity: 'nit', msg: 'Line is quite long (>120 chars) — consider wrapping.', line: trimmed.slice(0, 60) + '…' });
    }
    if (/==[^=]/.test(trimmed) && !/===|!==/.test(trimmed)) {
      findings.push({ severity: 'nit', msg: 'Loose equality (==) used — consider === for clarity.', line: trimmed });
    }
  });

  const filesChanged = (diff.match(/^diff --git/gm) || []).length;
  return { findings, filesChanged, linesAdded: addedLines.length };
}

async function llmReview(diff) {
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key || !diff.trim()) return null;
  try {
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-6',
        max_tokens: 800,
        messages: [{
          role: 'user',
          content: `You are a thorough but concise code reviewer. Review this diff and list concrete, actionable issues (bugs, style, security, missing tests), grouped by severity (critical/warning/nit/info). Keep it under 300 words.\n\n${diff.slice(0, 8000)}`,
        }],
      }),
    });
    const data = await res.json();
    return (data.content || []).map((b) => b.text || '').join('\n').trim() || null;
  } catch {
    return null;
  }
}

function printHeuristicReport(report) {
  const { findings, filesChanged, linesAdded } = report;
  console.log(`\n🔎 codereviewer-lite — heuristic review (${filesChanged} file(s), ${linesAdded} added line(s))\n`);
  if (findings.length === 0) {
    console.log('✔ No issues found by the heuristic checks. Nice and clean!\n');
    return;
  }
  const order = { critical: 0, warning: 1, nit: 2, info: 3 };
  findings.sort((a, b) => order[a.severity] - order[b.severity]);
  const icons = { critical: '🛑', warning: '⚠️ ', nit: '💡', info: 'ℹ️ ' };
  for (const f of findings) {
    console.log(`${icons[f.severity]} [${f.severity.toUpperCase()}] ${f.msg}`);
    console.log(`    ${f.line}`);
  }
  console.log(`\nTotal findings: ${findings.length}\n`);
}

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const [k, v] = a.slice(2).split('=');
      args[k] = v === undefined ? true : v;
    }
  }
  return args;
}

async function main() {
  const [, , cmd, ...rest] = process.argv;
  const args = parseArgs(rest);

  if (cmd !== 'review') {
    console.log('codereviewer-lite — local AI code review\n');
    console.log('Usage:');
    console.log('  review               review HEAD vs main');
    console.log('  review --base <ref>  review HEAD vs a different base branch');
    console.log('  review --staged      review only staged changes');
    return;
  }

  const diff = getDiff({ base: typeof args.base === 'string' ? args.base : null, staged: !!args.staged });
  if (!diff.trim()) {
    console.log('No changes found to review (try staging something or check your base branch).');
    return;
  }

  const aiReview = await llmReview(diff);
  if (aiReview) {
    console.log('\n🤖 codereviewer-lite — AI review (Claude)\n');
    console.log(aiReview);
    console.log('');
  } else {
    console.log('(No ANTHROPIC_API_KEY set — using built-in heuristic review. Set the env var for deeper AI feedback.)');
  }

  const report = heuristicReview(diff);
  printHeuristicReport(report);
}

if (require.main === module) {
  main().catch((err) => {
    console.error('Error:', err.message);
    process.exit(1);
  });
}

module.exports = { heuristicReview, getDiff };
