#!/usr/bin/env bash
# Export the current conda environment into environment.yml, conda_requirements.txt, and pip_requirements.txt
# Usage: ./scripts/export_env.sh <conda_env_name>
set -euo pipefail

ENV_NAME="${1:-}"

if [[ -z "${ENV_NAME}" ]]; then
  echo "Usage: $0 <conda_env_name>"
  exit 1
fi

if ! command -v conda >/dev/null 2>&1; then
  echo "Error: 'conda' not found in PATH."
  exit 1
fi

# Initialize conda for non-interactive shells
CONDA_BASE="$(conda info --base)"
if [[ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]]; then
  # shellcheck disable=SC1091
  source "$CONDA_BASE/etc/profile.d/conda.sh"
fi

echo ">> Activating environment: $ENV_NAME"
conda activate "$ENV_NAME"

echo ">> Exporting portable YAML (no builds) -> environment.yml"
conda env export --no-builds > environment.yml

echo ">> Exporting conda-only specs -> conda_requirements.txt"
# 'conda list --export' lists only conda-managed packages with pinned versions.
conda list --export > conda_requirements.txt

echo ">> Exporting pip-only specs -> pip_requirements.txt"
# Exclude bootstrap tools to keep the list clean
pip list --format=freeze | grep -vE '^(pip|setuptools|wheel)==' > pip_requirements.txt

# Timestamp marker
date -u +"%Y-%m-%dT%H:%M:%SZ" > LAST_EXPORTED_UTC.txt

echo "✅ Export complete: environment.yml, conda_requirements.txt, pip_requirements.txt"
