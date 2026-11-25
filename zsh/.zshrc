# ~/.zshrc — Modern Zsh Configuration

# --- Homebrew ---
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Editor ---
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# --- History ---
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Record timestamp and duration
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS         # Do not display duplicates when searching
setopt HIST_IGNORE_SPACE         # Ignore commands starting with a space
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt SHARE_HISTORY             # Share history across all sessions

# --- Shell Behavior ---
setopt AUTO_CD                   # Type a directory name to cd into it
setopt AUTO_PUSHD                # Push old directory onto stack on cd
setopt PUSHD_IGNORE_DUPS         # Do not push duplicate directories
setopt PUSHD_SILENT              # Do not print directory stack
setopt INTERACTIVE_COMMENTS      # Allow # comments in interactive shell
setopt NO_BEEP                   # Disable terminal beep

# --- Keybindings ---
bindkey -e                       # Emacs keybindings (Ctrl-A, Ctrl-E, Ctrl-W, etc.)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # Up arrow: search history matching prefix
bindkey "^[[B" down-line-or-beginning-search  # Down arrow: search history matching prefix

# --- Completion ---
autoload -Uz compinit
# Rebuild compdump only once every 24 hours for faster startup
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# --- Modern CLI Tools ---
# fzf: Ctrl-R (history), Ctrl-T (files), Alt-C (directories)
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
fi

# zoxide: smart directory jumping (use `z <dir>` or `zi` for interactive)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  # Uncomment the line below if you want `cd` to use zoxide directly:
  # alias cd="z"
fi

# eza: modern ls replacement (with Nerd Font icons)
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=auto --group-directories-first"
  alias ll="eza -la --icons=auto --group-directories-first --git"
  alias la="eza -a --icons=auto --group-directories-first"
  alias lt="eza --tree --level=2 --icons=auto --group-directories-first"
else
  alias ll="ls -lah"
  alias la="ls -lAh"
fi

# bat: modern cat replacement
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# --- Useful Aliases & Functions ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias reload="source ~/.zshrc && echo 'Reloaded ~/.zshrc'"

# Git shortcuts
alias gs="git status -sb"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate -n 20"
alias gd="git diff"

# Create a directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# --- Plugins ---
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# zsh-ssh: fzf-powered SSH host completion (https://github.com/sunlei/zsh-ssh)
if [[ -f "$HOME/.zsh/zsh-ssh/zsh-ssh.zsh" ]]; then
  export ZSH_SSH_SORT_RECENT=1
  export ZSH_SSH_INCLUDE_KNOWN_HOSTS=1
  source "$HOME/.zsh/zsh-ssh/zsh-ssh.zsh"
fi

if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# zsh-syntax-highlighting must be sourced after other plugins/widgets
if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# --- Starship Prompt ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
