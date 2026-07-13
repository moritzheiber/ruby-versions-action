const { execFileSync } = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const assert = require("node:assert");

const IMAGE = "ruby-versions-action";
const SEMVER = /^\d+\.\d+\.\d+$/;

// Run the built action image with a mounted GITHUB_OUTPUT file and return its
// parsed step outputs.
const runAction = (env) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), "rva-"));
    const outputFile = path.join(dir, "output");
    const args = ["run", "--rm", "-v", `${dir}:/gh`, "-e", "GITHUB_OUTPUT=/gh/output"];
    for (const [key, value] of Object.entries(env)) {
        args.push("-e", `${key}=${value}`);
    }
    args.push(IMAGE);
    execFileSync("docker", args, { stdio: "inherit" });

    const outputs = {};
    for (const line of fs.readFileSync(outputFile, "utf8").split("\n")) {
        const index = line.indexOf("=");
        if (index !== -1) outputs[line.slice(0, index)] = line.slice(index + 1);
    }
    return outputs;
};

module.exports = async ({ core }) => {
    // Default behaviour: latest releases from ruby-lang.org.
    const releases = runAction({});
    const versions = JSON.parse(releases.versions);
    assert(Array.isArray(versions) && versions.length > 0, "versions must be a non-empty array");
    assert(versions.every((v) => SEMVER.test(v)), "versions must be semver strings");

    const metadata = JSON.parse(releases.metadata);
    assert(metadata.length === versions.length, "metadata length must match versions");
    assert(
        metadata.every((m) => m.version && m.url && m.checksum),
        "metadata entries must expose version, url and checksum",
    );
    core.info(`ruby-lang.org: ${versions.length} versions`);

    // Custom metadata key names.
    const renamed = runAction({ RVA_VERSION_NAME: "ruby", RVA_CHECKSUM_NAME: "ruby_checksum" });
    const renamedMetadata = JSON.parse(renamed.metadata);
    assert(
        renamedMetadata.every((m) => "ruby" in m && "ruby_checksum" in m && "url" in m),
        "custom key names must be applied",
    );
    core.info("custom key names applied");

    // Container-registry behaviour.
    const registry = runAction({ RVA_REPOSITORY: "library/ruby" });
    const tags = JSON.parse(registry.versions);
    assert(Array.isArray(tags) && tags.length > 0, "registry versions must be a non-empty array");
    assert(!("metadata" in registry), "registry mode must not emit metadata");
    core.info(`registry: ${tags.length} tags`);
};
