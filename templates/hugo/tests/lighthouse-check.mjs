#!/usr/bin/env node
import { mkdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import lighthouse from "lighthouse";
import desktopConfig from "lighthouse/core/config/desktop-config.js";
import puppeteer from "puppeteer";

const [, , url, thresholdArg, outDir] = process.argv;

if (!url || !thresholdArg || !outDir) {
  console.error("Usage: lighthouse-check.mjs <url> <threshold> <out-dir>");
  process.exit(1);
}

const threshold = Number(thresholdArg);
const categories = ["performance", "accessibility", "best-practices", "seo"];
const formFactors = [
  { name: "mobile", config: undefined },
  { name: "desktop", config: desktopConfig },
];
const themes = ["light", "dark"];
const blockedUrlPatterns = ["*googletagmanager.com*", "*google-analytics.com*"];

mkdirSync(outDir, { recursive: true });

const browser = await puppeteer.launch({
  headless: true,
  args: ["--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"],
});

let failed = false;

try {
  for (const formFactor of formFactors) {
    for (const theme of themes) {
      const page = await browser.newPage();
      await page.emulateMediaFeatures([{ name: "prefers-color-scheme", value: theme }]);

      const result = await lighthouse(
        url,
        {
          output: "json",
          logLevel: "error",
          onlyCategories: categories,
          blockedUrlPatterns,
        },
        formFactor.config,
        page,
      );

      await page.close();

      const label = `${formFactor.name} / ${theme}`;

      if (!result) {
        console.error(`Lighthouse produced no result for ${label}.`);
        failed = true;
        continue;
      }

      const reportPath = path.join(outDir, `${formFactor.name}-${theme}.json`);
      writeFileSync(reportPath, result.report);

      console.log(`\n${label} (${reportPath}):`);
      for (const category of categories) {
        const score = Math.round(result.lhr.categories[category].score * 100);
        const pass = score >= threshold;
        if (!pass) failed = true;
        console.log(`  ${pass ? "PASS" : "FAIL"}  ${result.lhr.categories[category].title.padEnd(16)} ${score}`);
      }
    }
  }
} finally {
  await browser.close();
}

if (failed) {
  console.error(`\nLighthouse score below ${threshold} for at least one category/theme.`);
  process.exit(1);
}
