import { execSync } from "child_process";

try {
	console.log("📦 1. Building code and running typechecks...");
	// Running your existing build task
	execSync("npm run build:prod", { stdio: "inherit" });

	console.log("\n📤 2. Pushing build assets to Google Apps Script...");
	execSync("clasp push", { stdio: "inherit" });

	console.log("\n🔍 3. Scanning active project deployments...");
	const deploymentsOutput = execSync("clasp deployments", { encoding: "utf-8" });

	// Regex targets Google's active deployment ID format (typically starts with AKfy...)
	const matches = deploymentsOutput.match(/AKfy[a-zA-Z0-9_-]+/g);

	if (!matches || matches.length === 0) {
		throw new Error(
			"Could not extract a valid deployment ID.\n" +
				'Please ensure you have created an initial deployment first using: "clasp create-deployment"',
		);
	}

	// Choose the last matched ID (the latest active production/webapp deployment)
	const targetId = matches[matches.length - 1];
	console.log(`🎯 Targeted Deployment ID: ${targetId}`);

	console.log(`\n🚀 4. Redeploying code in-place to the target ID...`);
	execSync(`clasp deploy -i ${targetId}`, { stdio: "inherit" });

	console.log("\n✨ Execution successfully completed! Backend updated.");
} catch (error) {
	console.error("\n❌ Deployment pipeline aborted due to an error:");
	console.error(error.message || error);
	process.exit(1);
}
