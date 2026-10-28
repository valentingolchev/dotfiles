# Dotfiles

## Dependencies

- [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html) (for dotfiles)
- [Nix](https://nixos.org/download) with flakes (for package management)

## Setup

Run the setup script from the repo root:

```bash
./setup.sh
```

This runs 4 steps, each checking if it's needed:

1. **Install Nix** — uses [NixOS experimental installer](https://github.com/NixOS/nix-installer) (Rust-based, SELinux-compatible, flakes enabled)
2. **Check home-manager** — bootstrapped in step 3 if needed
3. **Install packages** — via home-manager (`home.nix`)
4. **Stow dotfiles** — based on which packages are installed

The script is idempotent — safe to run multiple times.

### First-time setup

On a fresh machine, you may need to start a new shell after Nix installation:

```bash
./setup.sh          # installs Nix, may exit asking for new shell
# Start new shell, then:
./setup.sh          # completes remaining steps
```

### Manual steps

**Stow with conflict backup:**
```bash
./symlink_all.sh
```

**Stow specific directories:**
```bash
./symlink_all.sh --dirs "nvim zsh kitty"
```

**Dry run:**
```bash
./symlink_all.sh --dry-run
```

### Package management

Packages are managed by [home-manager](https://github.com/nix-community/home-manager) via `home.nix`.

**Update packages:**
```bash
home-manager switch --flake .
```

**Add a package:**
Edit `home.nix`:
```nix
home.packages = with pkgs; [
  neovim
  bat
  my-new-package  # ← add here
];
```
Then run: `home-manager switch --flake .`

**Rollback:**
```bash
home-manager generations
home-manager switch --rollback
```

**Check for package conflicts:**

After installing via home-manager, check if any packages are also installed via system package manager:

```bash
./scripts/check-package-conflicts.sh
```

This shows which packages are installed via Nix, system package manager, Homebrew, or manually, and provides uninstall commands for conflicts.

### Platform-specific packages

Packages are automatically selected based on OS:

```nix
home.packages = with pkgs; [
  # All platforms
  git stow neovim
] ++ lib.optionals pkgs.stdenv.isLinux [
  # Linux only
  wl-clipboard
] ++ lib.optionals pkgs.stdenv.isDarwin [
  # macOS only
  nerd-fonts.hack
];
```

### Multiple machines

Add host-specific configurations in `flake.nix`:

```nix
homeConfigurations = {
  "user@desktop" = mkHome "x86_64-linux" "user";
  "user@macbook" = mkHome "aarch64-darwin" "user";
};
```

Then run:
```bash
home-manager switch --flake .#user@desktop
home-manager switch --flake .#user@macbook
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

## LLM agent sandbox

Hardened podman sandbox for running LLM coding agents inside a project
(`llm_sandbox/`). Stowed by default; the runner lands on `PATH` as
`~/.local/bin/agent-sandbox`. On start it asks which stack image to run and
which harness to launch (claude, opencode, vibe, or a manual shell). Machine
defaults live in the stowed `~/.config/agent-sandbox/config` (all keys listed,
uncommented): `stack`, `harness`, `memory`, `cpus`, `no_network`,
`persist_caches`, `harness_state`, `env_keys`. `[path]` sections (TOML-style, `~` expands)
override the globals per project, with the longest matching path prefix
winning. Config values preselect the prompts; the env vars (`AGENT_IMAGE`,
`HARNESS`, ...) skip them entirely and always win.
The harness CLIs are installed in the base image, so they run in the base
image and every stack; `REBUILD=1` refreshes them.
Layered images: `agent-sandbox:base` plus per-stack variants.

Stacks: `python`, `node`, `rust`, `elixir`, `clojure`, `lua-nvim`, `web-cljs`,
`react-native-cljs`.

From a project root:

```bash
agent-sandbox                                  # base image
AGENT_IMAGE=agent-sandbox:elixir agent-sandbox
HARNESS=opencode agent-sandbox
```

See the header of `llm_sandbox/.local/bin/agent-sandbox` for options
(`REBUILD`, `NO_NETWORK`, `PERSIST_CACHES`, `ENV_KEYS`). Requires rootless
podman on the host (Fedora: `sudo dnf install podman`;
Ubuntu: `sudo apt-get install podman uidmap`).
