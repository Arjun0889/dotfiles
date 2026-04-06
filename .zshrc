# OS Detection
os_name="$(uname -s)"

# --------------------------------------
# ✅ Homebrew (macOS only)
# Sets HOMEBREW_PREFIX used by later sections
if [[ "$os_name" == "Darwin" ]]; then
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# --------------------------------------
# ✅ Zinit Setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Synchronous: completions must load before compinit
zinit light zsh-users/zsh-completions

# Deferred: load after first prompt — shell is usable instantly while these finish
zinit wait lucid light-mode for \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab

# --------------------------------------
# ✅ Completions (cached — full audit once a day, fast cache otherwise)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
zinit cdreplay -q

# --------------------------------------
# ✅ Oh-My-Posh prompt
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config ~/.ohmyposh/zen.toml)"
fi

# --------------------------------------
# ✅ Keybindings (emacs mode)
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# --------------------------------------
# ✅ History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# --------------------------------------
# ✅ Completion Styling
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

# --------------------------------------
# ✅ Aliases
if [[ "$os_name" == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

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
alias pk='pkill audiosessiond'

# --------------------------------------
# ✅ Tmux
# Auto-start: every new terminal lands in "home" session
# Navigate to other sessions with: Ctrl+b s
if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && command -v tmux &>/dev/null; then
    exec tmux new-session -A -s home
fi

# t <name> → attach to named session (or create it), t alone → "home"
t() {
    local session=${1:-home}
    # Create session if it doesn't exist (silent if it does)
    tmux new-session -d -s "$session" 2>/dev/null
    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$session"   # inside tmux — switch to it
    else
        tmux attach -t "$session"          # outside tmux — attach to it
    fi
}
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias td='tmux detach'

# Keep Mac awake for remote Claude sessions (screen can lock, system stays up)
alias wake='caffeinate -i & disown; echo "Caffeinated. Run: uncafe to stop."'
alias uncafe='pkill caffeinate && echo "Caffeinate stopped."'

# --------------------------------------
# ✅ Shell Integrations
if command -v fzf &> /dev/null; then
    if fzf --zsh &> /dev/null; then
        eval "$(fzf --zsh)"
    else
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
# ✅ JENV (Java — multiple versions managed)
if [[ -d "$HOME/.jenv" ]]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# --------------------------------------
# ✅ PostgreSQL@17
# Uses $HOMEBREW_PREFIX (set by brew shellenv above) — no subprocess spawn
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    POSTGRES_PATH="$HOMEBREW_PREFIX/opt/postgresql@17"
    if [[ -d "$POSTGRES_PATH/bin" ]]; then
        export PATH="$POSTGRES_PATH/bin:$PATH"
        export LDFLAGS="-L$POSTGRES_PATH/lib${LDFLAGS:+ $LDFLAGS}"
        export CPPFLAGS="-I$POSTGRES_PATH/include${CPPFLAGS:+ $CPPFLAGS}"
    fi
    unset POSTGRES_PATH
fi

# --------------------------------------
# ✅ System PATHs
if [[ "$os_name" == "Darwin" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="$PATH:$HOME/bin"
if [[ "$os_name" == "Darwin" ]]; then
    export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
fi

# --------------------------------------
# ✅ Google Cloud SDK
if [ -f "$HOME/gcloud-cli-software/google-cloud-sdk/path.zsh.inc" ]; then
    . "$HOME/gcloud-cli-software/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/gcloud-cli-software/google-cloud-sdk/completion.zsh.inc" ]; then
    . "$HOME/gcloud-cli-software/google-cloud-sdk/completion.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# --------------------------------------
# ✅ GPG
if [ -n "$TTY" ]; then
    export GPG_TTY=$(tty)
else
    export GPG_TTY="$TTY"
fi

# --------------------------------------
# ✅ Google Cloud Credentials
if [ -f "$HOME/gcp_keng02.json" ]; then
    export GCP_JSON="$HOME/gcp_keng02.json"
    export GOOGLE_APPLICATION_CREDENTIALS="$GCP_JSON"
fi

# --------------------------------------
# ✅ Antigravity
if [ "$USER" = "arjun" ] && [ "$(uname -s)" = "Darwin" ]; then
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
    export KUBECONFIG="$HOME/.kube/homelab-config"
fi

# --------------------------------------
# ✅ NVM (lazy-loaded — only initialises when you first use node/npm/nvm)
# Saves ~250ms on every shell open. First use triggers real load once per session.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
    unset -f nvm node npm npx yarn pnpm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm()  { _load_nvm; nvm  "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm  "$@"; }
npx()  { _load_nvm; npx  "$@"; }
yarn() { _load_nvm; yarn "$@"; }
pnpm() { _load_nvm; pnpm "$@"; }
