import fs from "node:fs/promises";
import path from "node:path";

const distPath = path.resolve("dist");
const keepFile = "appsscript.json";

try {
	await fs.mkdir(distPath, { recursive: true });
	const entries = await fs.readdir(distPath, { withFileTypes: true });

	for (const entry of entries) {
		if (entry.name === keepFile) {
			continue;
		}

		const entryPath = path.join(distPath, entry.name);

		await fs.rm(entryPath, {
			recursive: true,
			force: true,
		});
	}

	console.log("Cleaned dist directory (except appsscript.json)");
} catch (error) {
	console.error("Failed to clean dist directory:", error);
	process.exit(1);
}
