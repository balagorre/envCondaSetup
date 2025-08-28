#!/usr/bin/env bash
# Recreate an environment from files in this repo.
# Usage: ./scripts/recreate_env.sh <target_env_name>
set -euo pipefail

ENV_NAME="${1:-}"

if ! command -v conda >/dev/null 2>&1; then
  echo "Error: 'conda' not found in PATH."
  exit 1
fi

CONDA_BASE="$(conda info --base)"
if [[ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]]; then
  # shellcheck disable=SC1091
  source "$CONDA_BASE/etc/profile.d/conda.sh"
fi

# If environment.yml exists, prefer it
if [[ -f "environment.yml" ]]; then
  echo ">> Creating/updating environment from environment.yml"
  # Create if missing; if it exists, update
  if ! conda env create -f environment.yml 2>/dev/null; then
    conda env update -f environment.yml --prune
  fi

  # Try to derive the env name from YAML if user didn't pass one
  YAML_NAME="$(awk '/^name:/ {print $2; exit}' environment.yml || true)"
  if [[ -z "${ENV_NAME}" && -n "${YAML_NAME}" ]]; then
    ENV_NAME="${YAML_NAME}"
  fi
else
  if [[ -z "${ENV_NAME}" ]]; then
    echo "Usage: $0 <target_env_name>"
    echo "  (or include an environment.yml in this directory)"
    exit 1
  fi

  echo ">> Creating environment '${ENV_NAME}' from conda_requirements.txt"
  conda create -n "${ENV_NAME}" --file conda_requirements.txt -y

  echo ">> Activating '${ENV_NAME}'"
  conda activate "${ENV_NAME}"

  if [[ -f "pip_requirements.txt" ]]; then
    echo ">> Installing pip packages from pip_requirements.txt"
    pip install -r pip_requirements.txt
  fi

  echo "✅ Environment '${ENV_NAME}' ready"
  exit 0
fi

if [[ -n "${ENV_NAME}" ]]; then
  echo ">> Activating '${ENV_NAME}'"
  conda activate "${ENV_NAME}" || true
fi

echo "✅ Done. If activation failed, check the env name defined in environment.yml."
