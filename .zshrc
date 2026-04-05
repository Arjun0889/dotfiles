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
alias gpu='git pull --rebase'
alias gps='git push'
alias gs='git status'

# --------------------------------------
# ✅ Tmux
# --------------------------------------

# Smart attach/create: t <name> or just t for "main"
# t          → attach to "main" session (or create it)
# t work     → attach to "work" session (or create it)
# t dotfiles → attach to "dotfiles" session (or create it)
t() {
  local session=${1:-main}
  tmux new-session -A -s "$session"
}

# Session management aliases
alias tl='tmux list-sessions'       # tl          — list all running sessions
alias tk='tmux kill-session -t'     # tk <name>   — kill a session
alias td='tmux detach'              # td          — detach (session keeps running in bg)

# Keep Mac awake for remote Claude sessions (screen locks, system stays up)
# Plugged in? Use System Settings → Battery → Prevent sleeping on power adapter instead.
alias wake='caffeinate -i & disown; echo "Caffeinated. Run: uncafe to stop."'
alias uncafe='pkill caffeinate && echo "Caffeinate stopped."'

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
# ✅ Conda Configuration
# Prevent conda from modifying the prompt (let Oh My Posh handle it)
export CONDA_CHANGEPS1=false

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Ensure conda's Python takes precedence over pyenv when activated
_manage_conda_pyenv_path() {
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        # Conda is active - remove pyenv from PATH if present
        if [[ "$PATH" == *"/.pyenv/"* ]]; then
            PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '/.pyenv/' | tr '\n' ':' | sed 's/:$//')"
            export PATH
        fi
    else
        # Conda is fully deactivated - restore pyenv if not already in PATH
        if [[ -d "$HOME/.pyenv" ]] && [[ "$PATH" != *"/.pyenv/"* ]]; then
            export PATH="$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH"
        fi
    fi
}

# Only wrap conda if it was successfully initialized
if typeset -f conda > /dev/null 2>&1; then
    # Save the original conda function created by conda init
    functions[_original_conda]=$functions[conda]

    # Wrap conda to manage PATH after activate/deactivate
    conda() {
        _original_conda "$@"
        local ret=$?
        if [[ "$1" == "activate" ]] || [[ "$1" == "deactivate" ]]; then
            _manage_conda_pyenv_path
        fi
        return $ret
    }
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
# ✅ PostgreSQL@17 (Homebrew on macOS or Linux)
if command -v brew &> /dev/null; then
    POSTGRES_PATH="$(brew --prefix postgresql@17 2>/dev/null)"
    if [[ -n "$POSTGRES_PATH" ]] && [[ -d "$POSTGRES_PATH/bin" ]]; then
        export PATH="$POSTGRES_PATH/bin:$PATH"
        # For compilers
        export LDFLAGS="-L$POSTGRES_PATH/lib${LDFLAGS:+ $LDFLAGS}"
        export CPPFLAGS="-I$POSTGRES_PATH/include${CPPFLAGS:+ $CPPFLAGS}"
    fi
    unset POSTGRES_PATH
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

alias pk='pkill audiosessiond'

# ✅ Antigravity (only for user 'arjun' on mac)
if [ "$USER" = "arjun" ] && [ "$(uname -s)" = "Darwin" ]; then
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
    export KUBECONFIG="$HOME/.kube/homelab-config"
fi
# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/arjun/.antigravity/antigravity/bin:$PATH"
