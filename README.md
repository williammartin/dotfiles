# dotfiles

Standardized macOS machine setup using:

- `bootstrap.sh` as the single idempotent entrypoint
- Homebrew Bundle for packages (`Brewfile`)
- `chezmoi` for dotfile state (`chezmoi/`)

## Repository layout

- `bootstrap.sh`: top-level setup entrypoint
- `scripts/`: reusable setup steps
- `chezmoi/`: source state managed by chezmoi

## Quick start (new machine)

One-liner from a bare machine:

```bash
curl -fsSL https://raw.githubusercontent.com/williammartin/dotfiles/johnmog-dotfiles-bootstrap/install.sh | bash
```

Manual:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Dry run:

```bash
./bootstrap.sh --dry-run
```

## Standard workflows

- First run on a new machine:
  - clone repo
  - run `./bootstrap.sh`
- Update an existing machine:
  - pull latest changes
  - re-run `./bootstrap.sh` (safe to re-run)
- Rollback package changes:
  - revert the relevant Brewfile commit
  - run `brew bundle --file Brewfile`
- Rollback dotfile changes:
  - run `chezmoi diff` to inspect
  - restore previous commit, then run `chezmoi apply`
- Add/remove apps:
  - edit `Brewfile`
  - run bootstrap again and commit changes
- Add/remove zsh plugins:
  - edit `chezmoi/dot_zsh_plugins.txt`
  - run `chezmoi apply`
- Pull in local Copilot skills:
  - run `./scripts/import-copilot-skills.sh`
  - add `--delete` if you want to prune files removed from `~/.copilot/skills`
  - commit `chezmoi/private_dot_copilot/private_skills/*`
  - run `chezmoi apply` on new machines
- Pull in local gh helper scripts (`fr.sh`, `worktree.sh`):
  - run `./scripts/import-gh-scripts.sh`
  - commit `chezmoi/private_dot_local/private_bin/executable_*.sh`
  - run `chezmoi apply` on new machines
