# Dotfiles

## Dependencies

[GNU Stow](https://www.gnu.org/software/stow/manual/stow.html)

## Setup

From the repo root, run the OS-aware setup script:

```bash
./setup.sh
```

### Setup options

```bash
./setup.sh --dry-run
./setup.sh --no-tui
./setup.sh --select-none
./setup.sh --dirs "zsh fzf"
./setup.sh --verbose
./setup.sh --help
```

### Presets

You can preselect groups and options using preset files:

- Repo preset: `.setup-preset`
- User preset: `~/.config/dotfiles/setup-preset`

Example preset:

```text
dirs=bat fzf zsh
tui=true
select_none=false
dry_run=false
verbose=true
```

### Symlink-only setup

```bash
./symlink_only.sh
```

### OS-specific help

```bash
./setup_macos.sh --help
./setup_linux.sh --help
```

## Usage

In order to symlink a specific package to $HOME you need to run the following command:

```bash
stow <package> -v -t ~
```

Example:

```bash
stow zsh
```
