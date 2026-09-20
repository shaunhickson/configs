# configs

nix-darwin + home-manager configuration for a macOS machine, plus the dotfiles
it links into place.

Config and tooling live here. Documents live in Dropbox. Neither is tied to a
particular machine.

## Bootstrap on a new Mac

Steps 1–2 are prerequisites; the rest is this repo.

1. **Xcode Command Line Tools** — needed before you can clone anything.

       xcode-select --install

2. **Determinate Nix.** This config sets `nix.enable = false`, meaning nix-darwin
   does *not* manage the nix installation itself — Determinate does.

       curl -fsSL https://install.determinate.systems/nix | sh -s -- install

3. **Clone.**

       git clone git@github.com:shaunhickson/configs.git ~/src/configs

4. **Build and activate.** `rebuild.sh` symlinks the repo to `~/.configs` (the
   stable path the dotfile links resolve through) and then activates.

       cd ~/src/configs && ./rebuild.sh

   Homebrew installs itself via nix-homebrew on first run, then the casks.

5. **Sign in by hand.** These are credentials, so they are deliberately not in
   the repo and cannot be automated:

   - Dropbox — launch and sign in
   - `gh auth login` — writes `~/.config/gh/hosts.yml`, which is gitignored
   - `gcloud auth login` — writes to `~/.local/state/gcloud`
   - Docker Desktop — launch once; it installs privileged helpers and will ask
     for admin rights

## Layout

| Path | What it is |
|---|---|
| `flake.nix` | Inputs. Two nixpkgs: `nixpkgs` (26.05) and `nixpkgs-unstable` |
| `configuration.nix` | System: macOS defaults, Homebrew casks, fonts, env vars |
| `home-manager/home.nix` | User: packages, zsh, and the dotfile links |
| `ghostty/`, `nvim/`, `zsh/`, `git/`, `gh/`, `starship.toml` | Files linked into `~/.config` |
| `rebuild.sh` | Symlinks `~/.configs`, then `darwin-rebuild switch` |

## Conventions

**Where a package goes.** CLI tools go in `home.packages`. Anything home-manager
has a module for (`starship`, `zoxide`, `zsh`) goes under `programs.<name>`, so
shell integration comes for free. GUI apps — especially ones installing
privileged helpers — stay Homebrew casks.

**Packages newer than the 26.05 pin.** Write `unstable.<name>` in
`home.packages`. That resolves through an overlay over the `nixpkgs-unstable`
input, so one package can run ahead without moving the rest of the system.

**Dotfiles are linked, not generated.** `home.nix` uses `mkOutOfStoreSymlink`,
so `~/.config/ghostty/config` and friends point at the working tree. Edit them
and the change is live — no rebuild. A rebuild is only needed when `.nix` files
change.

**`~/.config` is an ordinary directory.** Only the files listed under
`xdg.configFile` are linked in from here. Tool state, caches and credentials
stay real files in `~/.config` and never touch git.

**`.gitignore` is an allowlist.** Everything is ignored; tracked files are opted
in explicitly. Adding a file means adding a `!` line for it. For a directory
that also collects state, re-ignore the contents and opt in the specific files —
see `gh/` for the pattern.

**Homebrew cleanup is `uninstall`, not `zap`.** Removing a cask from the list
uninstalls the app but leaves its user data. `zap` would delete the data too —
for example Docker's VM with every image and volume in it.

## Gotchas

- Use a cask's canonical token, not an alias (`wireshark-app`, not `wireshark`;
  `docker-desktop`, not `docker`). A mismatch makes activation uninstall and
  reinstall it every time.
- `sudo darwin-rebuild` can leave root-owned files in the repo. They stay
  invisible until something needs to *write* them — `flake.lock` and a git
  object both did. Fix with
  `sudo chown -R "$USER":staff ~/src/configs`.
- A flake input only says where a module comes from. It still has to be
  *imported* before its options exist.
