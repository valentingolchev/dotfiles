# Based off of Greg Panders custom prompt: https://github.com/gpanders/dotfiles/blob/master/.config/fish/conf.d/prompt.fish
# 
# Originally based off of Jorge Bucaran (@jorgebucaran)'s Hydro prompt: https://github.com/jorgebucaran/hydro
# 
# For OSC commands, see https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md

# Only run in interactive shells
[[ $- == *i* ]] || return

# Prompt delimiter
: ${MY_PROMPT_DELIM:=$'\uf0a9'}

# Colors (set these as you like)
: ${MY_COLOR_HOST_REMOTE:=magenta}
: ${MY_COLOR_CWD:=blue}
: ${MY_COLOR_VENV:=green}
: ${MY_COLOR_JOBS:=yellow}
: ${MY_COLOR_STATUS:=red}
: ${MY_COLOR_CMD_DURATION:=cyan}
: ${MY_COLOR_ERROR:=red}
: ${MY_COLOR_PROMPT_DELIM:=white}
: ${MY_COLOR_GIT:=magenta}

# Hostname for SSH
if [[ -n $SSH_TTY ]]; then
  PROMPT_HOST="%F{$MY_COLOR_HOST_REMOTE}%m%f:"
else
  PROMPT_HOST=""
fi

function __prompt_update_pwd() {
    # Set __prompt_pwd with color and replace $HOME with ~
    local pwd="${PWD/#$HOME/~}"
    PROMPT_PWD="%F{$MY_COLOR_CWD}$pwd%f"

    # Reset the location of the Git directory so that it can be rediscovered
    unset __prompt_git_dir

    # If current directory contains a .jj directory then skip Git discovery
    if [[ -d "$PWD/.jj" ]]; then
        __prompt_git_dir=""
    fi
}

# Python venv or nix-shell
function __prompt_venv() {
  if [[ -n $VIRTUAL_ENV ]]; then
    PROMPT_VENV="%F{$MY_COLOR_VENV}$(basename $VIRTUAL_ENV) %f"
  elif [[ -n $IN_NIX_SHELL ]]; then
    PROMPT_VENV="%F{$MY_COLOR_VENV}nix-shell %f"
  else
    PROMPT_VENV=""
  fi
}

function __prompt_update_jobs() {
  local njobs=$(jobs -p | wc -l | tr -d ' ')
  if [[ $njobs -eq 0 ]]; then
    PROMPT_JOBS=""
  else
    PROMPT_JOBS="%F{$MY_COLOR_JOBS}[$njobs] %f"
  fi
}

function __prompt_cmd_duration() {
  if [[ $CMD_DURATION -gt 1000 ]]; then
    local secs=$((CMD_DURATION/1000 % 60))
    local mins=$((CMD_DURATION/60000 % 60))
    local hours=$((CMD_DURATION/3600000))
    local dur=""
    (( hours > 0 )) && dur+="${hours}h"
    (( mins > 0 )) && dur+="${mins}m"
    (( secs > 0 )) && dur+="${secs}s"
    PROMPT_CMD_DURATION="%F{$MY_COLOR_CMD_DURATION}${dur} %f"
  else
    PROMPT_CMD_DURATION=""
  fi
}

function __prompt_exit_status() {
  local last_status=$?
  if [[ $last_status -eq 0 ]]; then
    PROMPT_STATUS=""
  else
    PROMPT_STATUS="%F{$MY_COLOR_STATUS}[$last_status]%f"
  fi
}

function __prompt_git() {
  if [[ -z "$PROMPT_GIT_DIR" && -d .git ]]; then
    PROMPT_GIT_DIR="$PWD/.git"
  fi
  if [[ -z "$PROMPT_GIT_DIR" ]]; then
    PROMPT_GIT=""
    return
  fi
  local branch action dirty upstream
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    branch="$branch"
    git diff --quiet 2>/dev/null || dirty="*"
    # Upstream status
    local count
    count=$(git rev-list --count --left-right @{u}...HEAD 2>/dev/null)
    case "$count" in
      ""|"0	0") upstream="" ;;
      "0	"*) upstream="%F{cyan}⇡ %f" ;;
      *"	0") upstream="%F{cyan}⇣ %f" ;;
      *) upstream="%F{cyan}⇡⇣ %f" ;;
    esac
    PROMPT_GIT="%F{$MY_COLOR_GIT}${branch}${dirty} ${action}${upstream}%f"
  else
    PROMPT_GIT=""
  fi
}

# Main prompt function
function precmd() {
  print -Pn "\e]0;%~\a"

  __prompt_update_pwd
  __prompt_venv
  __prompt_update_jobs
  __prompt_cmd_duration
  __prompt_exit_status
  __prompt_git
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd

setopt prompt_subst

NEWLINE=$'\n'

PROMPT='${PROMPT_VENV}${PROMPT_HOST}${PROMPT_PWD} ${PROMPT_GIT}${PROMPT_JOBS}${PROMPT_CMD_DURATION}${PROMPT_STATUS}${NEWLINE}%F{$MY_COLOR_PROMPT_DELIM}${MY_PROMPT_DELIM}%f '
