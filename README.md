# dotfiles

Personal development environment for Ubuntu >= 26.04 LTS.

Covers: **zsh + oh-my-zsh**, **starship** prompt, **git** with per-directory identities, **GPG** commit signing, **Docker Engine**, and a set of CLI tools.

---

## Quick start

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then follow the checklist printed at the end of the script.

---

## What `install.sh` does

All scripts are **idempotent** — safe to re-run if something fails mid-way.

### `01-packages.sh` — base apt packages
Installs: `zsh`, `git`, `curl`, `wget`, `gnupg`, `build-essential`, and transport helpers needed by later steps.

### `02-fonts.sh` — Nerd Fonts
Downloads and installs **JetBrainsMono Nerd Font** into `~/.local/share/fonts`.  
Required for Starship prompt icons and eza file-type icons to render correctly.

> After the install finishes, open your terminal preferences and set the font to **JetBrainsMono Nerd Font**.  
> To use a different family, edit `FONT_NAME` at the top of the script.

### `03-zsh.sh` — oh-my-zsh + plugins
- Installs [oh-my-zsh](https://ohmyz.sh/)
- Clones [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) into the custom plugins directory
- Sets zsh as the default shell (`chsh`)

### `04-tools.sh` — CLI tools
| Tool | Purpose |
|---|---|
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement (icons, git status in listings) |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — `Ctrl+R` history, `Ctrl+T` file search |
| [starship](https://starship.rs/) | Cross-shell prompt |
| [goto](https://github.com/iridakos/goto) | Directory bookmarks (`g <label>`) |
| [nvm](https://github.com/nvm-sh/nvm) | Node Version Manager |

### `05-docker.sh` — Docker Engine
- Removes any conflicting Ubuntu-packaged `docker.io` / `podman-docker`
- Adds Docker's official apt repository
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`
- Enables the daemon via systemd
- Adds the current user to the `docker` group (no `sudo` needed after re-login)

### `06-link.sh` — symlinks
Symlinks the versioned dotfiles into `~/`. Any file that already exists is **backed up** to `~/.dotfiles-backup/<timestamp>/` before being replaced.

Files symlinked:

| Source (repo) | Destination |
|---|---|
| `home/.zshrc` | `~/.zshrc` |
| `home/.gitconfig` | `~/.gitconfig` |
| `home/.gitignore` | `~/.gitignore` |
| `config/starship.toml` | `~/.config/starship.toml` |

> Git identity files (`~/.gitconfig-personal`, `~/.gitconfig-work-*`, `~/.gitconfig.local`) are **generated locally** by `setup-identities.sh` — they are never symlinked and never stored in this repo.

---

## GPG keys (manual step)

GPG private keys are **not stored** in this repository. Export them from your old machine and import on the new one.

**On the source machine — export:**
```bash
./scripts/export-gpg.sh [output-directory]
```

The script lists all installed secret keys, lets you pick which ones to export (by number or `all`), and writes each key to its own `<uid>.key.gpg.asc` file plus an `ownertrust.txt` in the chosen output directory.

Copy the exported files to the new machine (USB drive or encrypted transfer — **do not commit them**), then:

**On the target machine — import:**
```bash
./scripts/import-gpg.sh *.key.gpg.asc ownertrust.txt
```

Verify signing works:
```bash
echo test | gpg --clearsign
```

> `*.key.gpg.asc` and `ownertrust.txt` are listed in `.gitignore`.

---

## Git identities (run after install)

```bash
./scripts/setup-identities.sh
```

This script prompts you interactively and generates three types of files, none of which ever touch the repo:

**`~/.gitconfig.local`** — included by `~/.gitconfig` at the end; holds `[includeIf]` rules that map directories to identity files.

**`~/.gitconfig-personal`** — applied inside `~/projects/`. Always exactly one personal identity.

**`~/.gitconfig-work-<slug>`** — one file per work identity. You can configure as many as you need.

### Example session

```
==> Git identity setup
────────────────────────────────────────────────────────────
  Available GPG secret keys:
    ABC1234567890123  Jhon Doe <jhon.doe@example.com>
    DEF1234567890123  Jhon <jhon@example.net>

── Personal identity (applied inside ~/projects/) ──
  Full name: Jhon Doe
  Email: jhon.doe@example.com
  GPG signing key ID (leave blank to skip): ABC1234567890123

── Work identities ──
  How many work identities? [0]: 2

  Work identity 1:
    Directory (e.g. ~/work/client1): ~/work/client1
    Full name: Jhon
    Email: jhon@example.net
    Config file suffix (e.g. client1): client1
    GPG signing key ID (leave blank to skip): DEF1234567890123

  Work identity 2:
    Directory (e.g. ~/work/client2): ~/work/client2
    Full name: Jhon Doe
    Email: jhon@example.net
    Config file suffix (e.g. client2): client2
    GPG signing key ID (leave blank to skip):
```

This generates:
- `~/.gitconfig-personal`
- `~/.gitconfig-work-client1`
- `~/.gitconfig-work-client2`
- `~/.gitconfig.local` with three `[includeIf]` blocks

Re-run the script any time to add a new identity or update an existing one.

---

## After install checklist

- [ ] `./scripts/import-gpg.sh <files…>` — import GPG keys
- [ ] `./scripts/setup-identities.sh` — configure git identities
- [ ] Set terminal font to **JetBrainsMono Nerd Font** _(if not available try after logout)_
- [ ] Log out and back in (applies: zsh as default shell, docker group membership)

---

## Re-running individual scripts

Every script is safe to run on its own:

```bash
./scripts/setup-identities.sh   # add/update git identities
./scripts/04-tools.sh           # re-install / update CLI tools
./scripts/05-docker.sh          # re-install Docker
./scripts/06-link.sh            # re-apply symlinks after adding a new dotfile
```

---

## Repository layout

```
dotfiles/
├── install.sh                  ← run once on a fresh machine
├── .gitignore                  ← keeps GPG exports and generated files out of git
├── home/
│   ├── .zshrc                  ← shell config (oh-my-zsh, aliases, tools)
│   ├── .gitconfig              ← global git settings; loads ~/.gitconfig.local
│   └── .gitignore              ← global git ignores
├── config/
│   └── starship.toml           ← prompt layout and icons
└── scripts/
    ├── 01-packages.sh          ← apt base packages
    ├── 02-fonts.sh             ← JetBrainsMono Nerd Font
    ├── 03-zsh.sh               ← oh-my-zsh + zsh-autosuggestions
    ├── 04-tools.sh             ← eza, fzf, starship, goto, nvm
    ├── 05-docker.sh            ← Docker Engine + non-root access
    ├── 06-link.sh              ← symlink dotfiles into ~/
    ├── export-gpg.sh           ← interactive GPG key export helper (manual step)
    ├── import-gpg.sh           ← GPG key import helper (manual step)
    └── setup-identities.sh     ← interactive git identity generator
```
