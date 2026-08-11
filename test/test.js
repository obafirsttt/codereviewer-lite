const assert = require('assert');
const { heuristicReview } = require('../src/codereviewer.js');

function run() {
  const diff = 'diff --git a/x.js b/x.js\n+++ b/x.js\n+console.log("debug");\n+if (a == b) {}\n';
  const report = heuristicReview(diff);
  assert.ok(report.findings.length >= 2, 'should detect console.log and == issues');
  console.log('✔ codereviewer-lite tests passed');
}

run();
