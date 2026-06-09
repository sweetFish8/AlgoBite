import { spawn } from "node:child_process";
import { mkdir } from "node:fs/promises";
import net from "node:net";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const projectDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const outputDir = path.join(projectDir, "exports");

async function availablePort() {
  return await new Promise((resolve, reject) => {
    const server = net.createServer();
    server.unref();
    server.on("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      const port = typeof address === "object" && address ? address.port : 0;
      server.close(() => resolve(port));
    });
  });
}

async function waitForServer(url) {
  const deadline = Date.now() + 60_000;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      // Next.js is still starting.
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  throw new Error(`Editor did not start within 60 seconds: ${url}`);
}

const port = await availablePort();
const url = `http://127.0.0.1:${port}`;
const server = spawn(
  "npm",
  ["run", "dev", "--", "--port", String(port)],
  {
    cwd: projectDir,
    env: { ...process.env, NEXT_TELEMETRY_DISABLED: "1" },
    detached: true,
    stdio: ["ignore", "pipe", "pipe"],
  },
);

server.stdout.on("data", (chunk) => process.stdout.write(chunk));
server.stderr.on("data", (chunk) => process.stderr.write(chunk));

let browser;
try {
  await waitForServer(url);
  browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
  await page.addInitScript(() => {
    localStorage.removeItem("app-store-screenshots:project:v1");
  });
  await page.goto(url, { waitUntil: "domcontentloaded" });

  const exportButton = page.getByRole("button", { name: "Export bundle" });
  await exportButton.waitFor({ state: "visible", timeout: 30_000 });
  await mkdir(outputDir, { recursive: true });

  console.log("Rendering 24 App Store screenshots...");
  const [download] = await Promise.all([
    page.waitForEvent("download", { timeout: 10 * 60_000 }),
    exportButton.click(),
  ]);
  const outputPath = path.join(outputDir, download.suggestedFilename());
  await download.saveAs(outputPath);
  console.log(`Saved ${outputPath}`);
} finally {
  await browser?.close();
  try {
    process.kill(-server.pid, "SIGTERM");
  } catch {
    // The dev server already exited.
  }
}
