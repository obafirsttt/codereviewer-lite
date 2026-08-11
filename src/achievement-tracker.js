#!/usr/bin/env node
/**
 * achievement-tracker.js
 * Shows badge progress for codereviewer-lite and a Day 1 → Month 1 roadmap.
 *
 * Usage:
 *   node src/achievement-tracker.js            # show badge progress
 *   node src/achievement-tracker.js roadmap     # show the Day 1 -> Month 1 roadmap
 *
 * State is stored locally in .achievements.json (git-ignored) and updated
 * by calling recordAchievement() — the gh scripts under scripts/ can pipe
 * their success into this via `npm run tracker -- --record=<name>`.
 */

const fs = require('fs');
const path = require('path');

const STATE_FILE = path.join(process.cwd(), '.achievements.json');

const BADGES = [
  { key: 'quickdraw', label: 'Quickdraw', tiers: [{ name: 'Quickdraw', goal: 1 }] },
  { key: 'yolo', label: 'YOLO', tiers: [{ name: 'YOLO', goal: 1 }] },
  { key: 'publicist', label: 'Publicist', tiers: [{ name: 'Publicist', goal: 1 }] },
  {
    key: 'pull-shark',
    label: 'Pull Shark',
    tiers: [
      { name: 'Bronze', goal: 2 },
      { name: 'Silver', goal: 16 },
      { name: 'Gold', goal: 128 },
    ],
  },
  { key: 'pair-extraordinaire', label: 'Pair Extraordinaire', tiers: [{ name: 'Pair Extraordinaire', goal: 1 }] },
];

function loadState() {
  if (!fs.existsSync(STATE_FILE)) return {};
  try {
    return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
  } catch {
    return {};
  }
}

function saveState(state) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

function recordAchievement(key, count = 1) {
  const state = loadState();
  state[key] = (state[key] || 0) + count;
  saveState(state);
  return state;
}

function bar(pct, width = 24) {
  const filled = Math.round((pct / 100) * width);
  return '█'.repeat(filled) + '░'.repeat(width - filled);
}

function printProgress() {
  const state = loadState();
  console.log('\n📊 codereviewer-lite — Achievement Progress\n');
  for (const badge of BADGES) {
    const progress = state[badge.key] || 0;
    console.log(`  ${badge.label}`);
    for (const tier of badge.tiers) {
      const pct = Math.min(100, Math.round((progress / tier.goal) * 100));
      const done = progress >= tier.goal ? '✅' : '  ';
      console.log(`    ${done} ${tier.name.padEnd(8)} [${bar(pct)}] ${Math.min(progress, tier.goal)}/${tier.goal}`);
    }
    console.log('');
  }
  console.log('Tip: run `bash scripts/unlock-all.sh` to work toward these on GitHub.\n');
}

const ROADMAP = [
  { when: 'Day 1', task: 'Clone the repo, run scripts/setup.sh, npm install, npm test — confirm green CI.' },
  { when: 'Day 1', task: 'Run scripts/quickdraw.sh to open & close your first issue.' },
  { when: 'Day 2-3', task: 'Run scripts/yolo.sh to practice the branch → PR → merge flow.' },
  { when: 'Week 1', task: 'Run scripts/publicist.sh to cut your v1.0.0 release.' },
  { when: 'Week 1-2', task: 'Run scripts/pull-shark.sh 2 for the Bronze Pull Shark badge.' },
  { when: 'Week 2-3', task: 'Invite a collaborator and run scripts/pair-extraordinaire.sh together.' },
  { when: 'Week 3', task: 'Run scripts/pull-shark.sh 16 for Silver.' },
  { when: 'Month 1', task: 'Keep contributing real features/fixes; work toward scripts/pull-shark.sh 128 (Gold) over time.' },
  { when: 'Month 1', task: 'Review your GitHub profile achievements page and celebrate 🎉' },
];

function printRoadmap() {
  console.log('\n🗺️  codereviewer-lite — Day 1 → Month 1 Roadmap\n');
  for (const step of ROADMAP) {
    console.log(`  [${step.when.padEnd(9)}] ${step.task}`);
  }
  console.log('');
}

function main() {
  const args = process.argv.slice(2);
  const recordArg = args.find((a) => a.startsWith('--record='));

  if (recordArg) {
    const key = recordArg.split('=')[1];
    const state = recordAchievement(key);
    console.log(`Recorded achievement progress for "${key}". Current: ${state[key]}`);
    return;
  }

  if (args.includes('roadmap')) {
    printRoadmap();
    return;
  }

  printProgress();
}

if (require.main === module) {
  main();
}

module.exports = { loadState, saveState, recordAchievement, printProgress, printRoadmap, BADGES, ROADMAP };
