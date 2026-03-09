#!/usr/bin/env bash
set -euo pipefail

# KMP AGP 9.0 Migration Skill Installer
# Detects installed AI coding agents and copies the skill to the appropriate directory.

SKILL_NAME="kmp-agp9-migration"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="${SCRIPT_DIR}/${SKILL_NAME}"

GLOBAL=false
INSTALLED=0
SKIPPED=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install the KMP AGP 9.0 Migration skill for detected AI coding agents.

Options:
  --global    Install to user-level directories (~/) instead of project-level (./)
  --help      Show this help message

Supported agents:
  Claude Code   .claude/skills/
  Codex         .agents/skills/
  Gemini CLI    .agents/skills/
  Junie         .junie/skills/
  Cursor        .cursor/skills/
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)
            GLOBAL=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Error: Unknown option '$1'"
            echo "Run '$(basename "$0") --help' for usage."
            exit 1
            ;;
    esac
done

# Verify the skill source directory exists
if [[ ! -d "${SKILL_SOURCE}" ]]; then
    echo "Error: Skill directory not found at ${SKILL_SOURCE}"
    echo "Make sure you run this script from the repository root."
    exit 1
fi

if [[ "${GLOBAL}" == true ]]; then
    BASE_DIR="${HOME}"
    echo "Installing globally to ${BASE_DIR}/..."
else
    BASE_DIR="$(pwd)"
    echo "Installing to project directory ${BASE_DIR}/..."
fi

# install_skill TARGET_DIR AGENT_NAME
# Copies the skill into TARGET_DIR/SKILL_NAME, creating the directory if needed.
install_skill() {
    local target_dir="$1"
    local agent_name="$2"
    local full_target="${target_dir}/${SKILL_NAME}"

    mkdir -p "${target_dir}"

    if [[ -d "${full_target}" ]]; then
        echo "  Updating ${agent_name} skill at ${full_target}"
    else
        echo "  Installing ${agent_name} skill to ${full_target}"
    fi

    rm -rf "${full_target}"
    cp -r "${SKILL_SOURCE}" "${full_target}"
    INSTALLED=$((INSTALLED + 1))
}

# detect_and_install AGENT_DIR AGENT_NAME
# If the agent's parent config directory exists (or --global), install the skill.
detect_and_install() {
    local agent_skills_dir="${BASE_DIR}/$1"
    local agent_config_parent="${BASE_DIR}/$(dirname "$1")"
    local agent_name="$2"

    if [[ "${GLOBAL}" == true ]]; then
        # For global installs, always install to known agent directories
        install_skill "${agent_skills_dir}" "${agent_name}"
    elif [[ -d "${agent_config_parent}" ]]; then
        # For project-level installs, only install if the agent config dir exists
        install_skill "${agent_skills_dir}" "${agent_name}"
    else
        echo "  Skipping ${agent_name} (no ${agent_config_parent} directory found)"
        SKIPPED=$((SKIPPED + 1))
    fi
}

echo ""
echo "Detecting agents..."
echo ""

# Claude Code
detect_and_install ".claude/skills" "Claude Code"

# Codex / Gemini CLI (shared directory)
detect_and_install ".agents/skills" "Codex / Gemini CLI"

# Junie
detect_and_install ".junie/skills" "Junie"

# Cursor
detect_and_install ".cursor/skills" "Cursor"

echo ""

if [[ ${INSTALLED} -gt 0 ]]; then
    echo "Done. Installed skill for ${INSTALLED} agent(s)."
else
    echo "No agents detected. To install anyway, use --global or create the agent"
    echo "config directory first (e.g., mkdir -p .claude) and re-run."
fi

if [[ ${SKIPPED} -gt 0 ]]; then
    echo "(${SKIPPED} agent(s) skipped -- config directory not found)"
fi
