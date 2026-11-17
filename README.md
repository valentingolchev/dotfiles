# Dotfiles

Nix + home-manager + GNU Stow dotfiles for Linux and macOS.

## Requirements

- Linux or macOS
- `git`, `curl`, `bash`, and `sudo` for the shell-symlink step
- Nix and Stow are installed by `./setup.sh` if missing

## Quick start

```bash
git clone https://github.com/valentingolchev/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

If this is the first run and Nix was just installed, start a new shell and run `./setup.sh` again. The script is idempotent.

`./setup.sh` runs six checks/steps:

1. Install Nix if missing.
2. Write `/etc/nix/nix.conf`: `experimental-features = nix-command flakes` and add you to `trusted-users` (sudo; restricted settings are only honored from the system config).
3. Check for `home-manager` (it is bootstrapped in step 4 if needed).
4. Apply packages from `home.nix` via home-manager.
5. On Linux, point `/usr/bin/zsh` at the Nix zsh if needed.
6. Stow dotfile directories whose tools are installed.

## Layout

Each Stow package lives under `stow/`: `stow/claude`, `stow/nvim`, `stow/opencode` (stow dir: `<repo>/stow`); fonts come from `nerd-fonts.*` packages in `home.nix` (`home.packages`). The `bat`, `btop`, `eza`, `fastfetch`, `fzf`, `idea`, `k9s`, `ripgrep`, `tinty`, `yazi` configs plus `bin`, `hypr`, `foot`, `kitty`, `zsh` are not stowed — they live in `files/` (which mirrors `$HOME`: `files/.config/...` -> `~/.config/...`) and are symlinked by home-manager via `home.nix` (`xdg.configFile`/`home.file`).

- `files/` — tree mirroring `$HOME`, symlinked into place by home-manager (`home.file`/`xdg.configFile` in `home.nix`)
- `modules/` — per-app home-manager modules (`hyprland.nix` — only when hyprland installed, `kitty.nix`, `foot.nix` — Linux only, `theming.nix`, `darkman.nix` — Linux only, `zsh.nix`); config sources stay in `files/` (`../files/...`). Rule: one definition style per file — dotted attrs (`xdg.configFile."x".source = …`) or a single attrset literal, never both in one file
- Only `stow/claude/`, `stow/nvim/`, `stow/opencode/` remain as stow packages. Everything else nix-managed lives in `files/`; on another machine run `./unstow-all.sh` before pulling (it sweeps stow links even if package dirs are gone). After pulling the move, re-run `./symlink_all.sh` (uses `--restow`) to re-point links that dangle at the old root.

`setup.sh` stows a package only when its command is installed (`nvim`), and always stows `claude`, `opencode` when present.

## Managing dotfiles

```bash
./symlink_all.sh --dry-run                 # preview
./symlink_all.sh                           # stow all existing default dirs
./symlink_all.sh --dirs "nvim claude"       # stow a subset
./unstow-all.sh                     # remove stow links for all nix-managed pkgs (run BEFORE pulling updates that delete old package dirs)
```

Conflicts are backed up automatically: `setup.sh` uses a `.backup-YYYYMMDD` suffix, `symlink_all.sh` moves files to `~/.dotfiles-backup/<timestamp>`.

Raw Stow, from the repo root:

```bash
stow --no-folding -d stow -t "$HOME" <dir>
```

## Packages

Packages are declared in `home.packages` in `home.nix`. After editing:

```bash
home-manager switch --impure --flake .#default
```

If `home-manager` is not on `PATH` yet, bootstrap it with:

```bash
nix run github:nix-community/home-manager -- switch --impure --flake .#default
```

Useful commands:

```bash
home-manager generations
home-manager switch --rollback
```

Linux/macOS differences are handled with `lib.optionals pkgs.stdenv.hostPlatform.isLinux/isDarwin` in `home.nix`. The flake exposes a single `default` home configuration that uses `--impure` and reads `$USER`/current system, so the same repo works per machine; add named `homeConfigurations` in `flake.nix` if you want pinned hosts.

## Theming

- Linux: `darkman` runs as a systemd user service and its `dark-mode.d/50-theme` / `light-mode.d/50-theme` hooks call `~/.local/bin/theme-hook <mode> <slug>`.
- macOS: the `theme-sync` launchd agent runs `~/.local/bin/theme-sync-macos` every 60s.
- `theme-hook` applies a `tinty` scheme and signals `foot` with USR1/USR2. `tinty` themes kitty, nvim, k9s, and Hyprland via `tinty/.config/tinted-theming/tinty/config.toml`; `foot` uses static `[colors-dark]`/`[colors-light]` sections in `foot.ini`.
- Defaults: dark `base16-kanagawa-dragon`, light `base16-kanagawa`.

Manual controls:

```bash
darkmanctl toggle        # Linux
darkmanctl set dark|light
tinty apply <slug>
tinty current
theme-defaults           # show effective defaults
theme-defaults <slug>    # override current mode
theme-defaults <dark> <light>
theme-defaults --clear   # back to home-manager defaults
```
