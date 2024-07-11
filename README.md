# Dotfiles

## Dependencies

[GNU Stow](https://www.gnu.org/software/stow/manual/stow.html)

## Setup

From the base folder run the corresponding command for your OS. Example:

```bash
setup_macos
```

## Usage

In oorder to symlink a specific package to $HOME you need to run the following command:

```bash
stow <package> -v -t ~
```

Example:

```bash
stow zsh
```

