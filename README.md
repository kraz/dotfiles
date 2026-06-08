# ~/.dotfiles

Personal environment configuration and setup

---

## Supported OS

| Distribution     | Edition            |
|------------------|--------------------|
| Ubuntu 26.04 LTS | Any desktop        |
| Fedora 44        | KDE Plasma Desktop |

## Quick start

```bash
git clone https://github.com/kraz/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer detects your OS automatically and uses the appropriate package manager (`apt` on Ubuntu, `dnf` on Fedora).

## Features
- All scripts are **idempotent** - safe to re-run if something fails mid-way.
- Symlinks the versioned dotfiles into `~/`. Any file that already exists is **backed up** to `~/.dotfiles-backup/<timestamp>/` before being replaced.
- GPG private keys are **not stored** in this repository. Export them from your old machine and import on the new one with the provided scripts.
- Git identity files (`~/.gitconfig-personal`, `~/.gitconfig-work-*`, `~/.gitconfig.local`) are **generated locally** by `setup-identities.sh` - they are never symlinked and never stored in this repo.

## License

This repository is considered personal, but you can use it under the MIT License if you find it useful. See the [LICENSE](LICENSE) file for details.
