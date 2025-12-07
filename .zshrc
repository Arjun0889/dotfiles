

# OS Detection
os_name="$(uname -s)"

# --------------------------------------
# ✅ Homebrew (macOS only)
if [[ "$os_name" == "Darwin" ]]; then
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"


# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
# zinit snippet OMZL::git.zsh
# zinit snippet OMZP::git
# zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
# zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Init oh-my-posh for zsh
# Make sure you have oh-my-posh installed and a config file at the specified path and changes as needed in the config file you provided below
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config ~/.ohmyposh/zen.toml)"
fi

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
if [[ "$os_name" == "Darwin" ]]; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -G $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -G $realpath'
else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

# Aliases
if [[ "$os_name" == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

# alias vim='nvim'
alias c='clear'
alias fman="compgen -c | fzf | xargs man"
alias k='kubectl'
alias sudo='sudo '
alias yt='noglob yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]" --merge-output-format mp4'
alias ytv='noglob yt-dlp -f "bestvideo[ext=mp4]"'
alias yta='noglob yt-dlp -f bestaudio -x --audio-format mp3'
alias ag='antigravity'

# Shell integrations
if command -v fzf &> /dev/null; then
    # Check if fzf supports --zsh (added in 0.48.0)
    if fzf --zsh &> /dev/null; then
        eval "$(fzf --zsh)"
    else
        # Fallback for older fzf
        source <(fzf --bash) 2>/dev/null || true # fzf --bash is also new, maybe just skip or use legacy sourcing if needed. 
        # Actually, standard legacy sourcing:
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    fi
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi


# --------------------------------------
# ✅ Remove Duplicate PATH Entries
typeset -U path PATH

# --------------------------------------
# ✅ JENV Configuration (for Java)
if [[ -d "$HOME/.jenv" ]]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# --------------------------------------
# ✅ PYENV Configuration (for Python)
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# --------------------------------------
# ✅ Homebrew (Apple Silicon) - Already handled at top, but keeping PATH export if needed for other tools
if [[ "$os_name" == "Darwin" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# --------------------------------------
# ✅ System Default PATHs (Keep at the Very End)
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$PATH:$HOME/bin"

if [[ "$os_name" == "Darwin" ]]; then
    export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/gcloud-cli-software/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/gcloud-cli-software/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/gcloud-cli-software/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/gcloud-cli-software/google-cloud-sdk/completion.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# ✅ GPG Setup (for signing/encryption)
if [ -n "$TTY" ]; then
  export GPG_TTY=$(tty)
else
  export GPG_TTY="$TTY"
fi

# --------------------------------------
# ✅ Google Cloud Credentials (set only if JSON exists)
if [ -f "$HOME/gcp_keng02.json" ]; then
    export GCP_JSON="$HOME/gcp_keng02.json"
    export GOOGLE_APPLICATION_CREDENTIALS="$GCP_JSON"
fi

# ✅ Antigravity (only for user 'arjun' on mac)
if [ "$USER" = "arjun" ] && [ "$(uname -s)" = "Darwin" ]; then
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
    export KUBECONFIG="$HOME/.kube/homelab-config"
fi