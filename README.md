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

`./setup.sh` runs five checks/steps:

1. Install Nix with flakes if missing.
2. Check for `home-manager` (it is bootstrapped in step 3 if needed).
3. Apply packages from `home.nix` via home-manager.
4. On Linux, point `/usr/bin/zsh` at the Nix zsh if needed.
5. Stow dotfile directories whose tools are installed.

## Layout

Each top-level directory is a Stow package: `claude`, `nvim`, `opencode`; fonts come from `nerd-fonts.*` packages in `home.nix` (`home.packages`). The `bat`, `btop`, `eza`, `fastfetch`, `fzf`, `idea`, `k9s`, `ripgrep`, `tinty`, `yazi` configs plus `bin`, `hypr`, `foot`, `kitty`, `zsh` are not stowed — they live in `files/` (which mirrors `$HOME`: `files/.config/...` -> `~/.config/...`) and are symlinked by home-manager via `home.nix` (`xdg.configFile`/`home.file`).

- `files/` — tree mirroring `$HOME`, symlinked into place by home-manager (`home.file`/`xdg.configFile` in `home.nix`)
- Only `claude/`, `nvim/`, `opencode/` remain as stow packages. Everything else nix-managed lives in `files/`; on another machine run `./unstow-all.sh` before pulling (it sweeps stow links even if package dirs are gone).

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
stow --no-folding -t "$HOME" <dir>
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
./scripts/check-package-conflicts.sh   # Nix vs system/brew/manual conflicts
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
