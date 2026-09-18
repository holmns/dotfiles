export GPG_TTY=$(tty)

# Over SSH there's no GUI, so tell gpg-agent's pinentry wrapper to use a
# terminal prompt (pinentry-curses) instead of the macOS dialog.
if [ -n "$SSH_CONNECTION" ]; then
  export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Async + Pure prompt
source /opt/homebrew/opt/zplug/repos/mafredri/zsh-async/async.zsh
fpath+=(/opt/homebrew/opt/zplug/repos/sindresorhus/pure)
autoload -U promptinit; promptinit
prompt pure

# Load secrets if available
if [ -f ~/.zsh_secrets ]; then
  source ~/.zsh_secrets
fi

# Auto suggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Git Aliases
alias ga="git add"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gu="git pull"
alias gco="git checkout"
alias gl="git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %d%n%s%n'"

# bun completions
[ -s "/Users/home/.bun/_bun" ] && source "/Users/home/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export EDITOR="nvim"
export VISUAL="nvim"

# Nvim Aliases
alias vim="nvim"

# Claude Code Alias
alias cc="claude"

# FZF Aliases
eval "$(zoxide init zsh)"
alias cdf="cd \$(find * -type d | fzf)"
source ~/fzf-git.sh/fzf-git.sh

alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Env
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# opencode
export PATH=/Users/home/.opencode/bin:$PATH


# >>> claude-auto-retry >>>
claude() {
  # Re-entry guard: if already running under auto-retry, just exec the real CLI.
  if [ "${CLAUDE_AUTO_RETRY_ACTIVE}" = "1" ]; then
    command claude "$@"
    return $?
  fi

  # Auto-retry (tmux monitor) is opt-in via --auto-retry. Strip the flag out
  # so it isn't forwarded to the claude CLI, which doesn't understand it.
  local _car_enabled=0
  local -a _car_args
  local _car_a
  for _car_a in "$@"; do
    if [ "$_car_a" = "--auto-retry" ]; then
      _car_enabled=1
    else
      _car_args+=("$_car_a")
    fi
  done

  # Default: no auto-retry, no tmux -- run the real CLI directly.
  if [ "$_car_enabled" != "1" ]; then
    command claude "$@"
    return $?
  fi

  export CLAUDE_AUTO_RETRY_ACTIVE=1
  local _car_old_int_trap _car_old_term_trap
  _car_old_int_trap=$(trap -p INT)
  _car_old_term_trap=$(trap -p TERM)
  trap 'unset CLAUDE_AUTO_RETRY_ACTIVE' INT TERM
  node "/Users/home/.npm-global/lib/node_modules/claude-auto-retry/src/launcher.js" "${_car_args[@]}"
  local _car_exit=$?
  unset CLAUDE_AUTO_RETRY_ACTIVE
  # Restore previous traps instead of clobbering them
  eval "${_car_old_int_trap:-trap - INT}"
  eval "${_car_old_term_trap:-trap - TERM}"
  return $_car_exit
}
# <<< claude-auto-retry <<<


# >>> ntu-hall-aircon >>>
aircon() {
  local path=~/code/hall-aircon
  "$path"/.venv/bin/python "$path"/main.py "$@"
}
# <<< ntu-hall-aircon <<<


# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

export PATH=$PATH:/Users/home/.spicetify

# Syntax highlighting (must be sourced last)
source /opt/homebrew/opt/zplug/repos/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm
export PNPM_HOME="/Users/home/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
