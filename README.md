# Environment Setup Repo

This repo captures and reproduces your Conda+pip environment cleanly.

## Quick Start

### Option A — Use `environment.yml` (recommended)

```bash
conda env create -f environment.yml
# If the env already exists:
conda env update -f environment.yml --prune
# Activate (uses the name defined inside environment.yml):
# conda activate <name_from_yaml>
```

### Option B — Use split files (conda + pip)

```bash
# Create and activate
conda create -n myenv --file conda_requirements.txt -y
conda activate myenv

# Then install pip packages
pip install -r pip_requirements.txt
```

---

## Exporting your current environment (kept in repo)

After you add or change packages, regenerate the files with:

```bash
./scripts/export_env.sh <your_env_name>
```

This updates:
- `environment.yml` (portable full spec)
- `conda_requirements.txt` (conda-only spec)
- `pip_requirements.txt` (pip-only spec excluding pip/setuptools/wheel)
- `LAST_EXPORTED_UTC.txt` (timestamp marker)

Commit and push these changes to keep the repo current.

---

## Recreating the environment on another machine

From a fresh clone of this repo:

```bash
# Preferred
./scripts/recreate_env.sh <target_env_name>

# Or do it manually:
conda env create -f environment.yml  # then conda activate <name_from_yaml>
# OR:
conda create -n <target_env_name> --file conda_requirements.txt -y
conda activate <target_env_name>
pip install -r pip_requirements.txt
```

> **Tip:** If `environment.yml` defines a different name than the one you want to use, either:
> - Use `./scripts/recreate_env.sh <target_env_name>` (it will try to activate the name in the YAML if present), or
> - Edit the `name:` in `environment.yml` before running the command.

---

## One-liners you may find handy

- List only the pip packages you installed (excludes bootstrap tools):

```bash
pip list --format=freeze | grep -vE '^(pip|setuptools|wheel)=='
```

- Save pip-only packages for migration:

```bash
pip list --format=freeze | grep -vE '^(pip|setuptools|wheel)==' > pip_requirements.txt
```

- Export everything into a single YAML:

```bash
conda env export --no-builds > environment.yml
```

---

## Windows notes

- Use **Anaconda Prompt** or **PowerShell** where `conda` is initialized.
- On Windows, the Bash scripts will run under **Git Bash** or **WSL**. Alternatively, copy the commands inside the scripts and run them manually in Anaconda Prompt.

---

## Best practices

- Prefer `conda install` when packages exist on conda channels for easier resolution.
- Use `pip install` for packages not available on conda.
- After changes, re-run `./scripts/export_env.sh <env>` and commit updates.
