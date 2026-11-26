import { defineConfig } from 'vitest/config';

// テストの結果は標準の出力と JUnit XML（test-results/junit.xml）に書く（YGO-062、.ai/environment.md §4.1）。
// skip と todo は通っていないと数える（scripts/check.sh が XML の skipped で失敗させる）。
export default defineConfig({
  test: {
    include: ['test/**/*.test.ts'],
    reporters: ['default', 'junit'],
    outputFile: { junit: 'test-results/junit.xml' },
    allowOnly: false,
    passWithNoTests: false,
  },
});
