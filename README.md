# KMP AGP 9.0 Migration Skill

An AI coding agent skill that migrates Kotlin Multiplatform projects to Android Gradle Plugin 9.0+.

## What It Does

- Replaces `com.android.library` with `com.android.kotlin.multiplatform.library` in KMP modules
- Splits KMP + application modules into separate app + shared library modules (required by AGP 9.0)
- Migrates DSL (`android {}` → `kotlin { android {} }`), source sets, and dependencies
- Handles built-in Kotlin migration (removes `kotlin-android`, migrates kapt → KSP)
- Checks third-party plugin compatibility and applies workarounds where needed
- Warns about known issues: BuildConfig removal, no build variants, NDK limitations, R8 changes, etc.

## Install

Clone the repo and run the installer from your project directory:

```bash
git clone https://github.com/Kotlin/kmp-agp9-migration.git
cd your-project/
../kmp-agp9-migration/install.sh
```

The script auto-detects which agents are configured in your project and copies the skill accordingly. Use `--global` to install to `~/` instead.

<details>
<summary>Manual install</summary>

```bash
git clone https://github.com/Kotlin/kmp-agp9-migration.git

# Claude Code
cp -r kmp-agp9-migration/kmp-agp9-migration .claude/skills/

# Junie
cp -r kmp-agp9-migration/kmp-agp9-migration .junie/skills/

# Codex / Gemini CLI
cp -r kmp-agp9-migration/kmp-agp9-migration .agents/skills/

# Cursor
cp -r kmp-agp9-migration/kmp-agp9-migration .cursor/skills/
```

</details>

## Structure

```
kmp-agp9-migration/
  SKILL.md               # Entry point — migration paths, steps, and decision logic
  references/            # DSL mapping, version matrix, known issues, per-path guides
  assets/                # Post-migration verification checklist
  scripts/               # Project analysis script
```

## License

Apache-2.0. See [LICENSE](LICENSE) for the full text.
