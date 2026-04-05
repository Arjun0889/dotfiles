# tmux — Learning Guide & Claude Code Productivity

---

## What is tmux?

Think of your terminal the way you think of a browser.

| Browser | tmux |
|---|---|
| The browser app | tmux server (runs invisibly in background) |
| Browser window | **Session** — a named workspace (e.g. "dotfiles", "work", "main") |
| Tab | **Window** — a full-screen view inside a session |
| Split view | **Pane** — a subdivided section of a window |
| Bookmark / restore tabs | tmux-resurrect / tmux-continuum |

The killer feature: **closing the browser window doesn't close the tabs**. You detach
from a session and it keeps running. SSH drops, laptop lid closes, screen locks —
your work is still there. Reattach and pick up exactly where you left off.

---

## The hierarchy

```
tmux server  (one per machine, starts automatically)
└── session: "main"
│   ├── window 1: "editor"   ← full screen
│   │   ├── pane (top-left): claude code
│   │   ├── pane (top-right): your files / git
│   │   └── pane (bottom): logs / command output
│   └── window 2: "scratch"
└── session: "work-project"
    └── window 1: "api"
        ├── pane: server running
        └── pane: testing
```

---

## Your prefix key

Everything in tmux starts with the **prefix**: `Ctrl+b`

You press prefix, release it, then press the command key.
It does not conflict with your emacs `Ctrl+a` (beginning-of-line) in the shell.

Think of it like the `Cmd` key on Mac — it's the modifier that tells tmux
"this next key is for you, not the shell."

---

## Daily commands — commit these to muscle memory

### Sessions

```bash
# From shell (outside tmux):
tn main              # new session named "main"
t home              # attach to "home"
tl                   # list sessions
tk main              # kill session

# Inside tmux:
prefix + d           # detach  (session keeps running — safe to close terminal)
prefix + $           # rename current session
prefix + s           # interactive session switcher (fuzzy pick)
```

### Windows (tabs)

```bash
prefix + c           # new window (opens in current directory)
prefix + n           # next window
prefix + p           # previous window
prefix + 1-9         # jump directly to window by number
prefix + ,           # rename current window
prefix + &           # close current window (asks for confirmation)
prefix + w           # visual window picker
```

### Panes (splits)

```bash
prefix + |           # split vertically   → two panes side by side
prefix + -           # split horizontally → pane above and below

prefix + h/j/k/l     # move between panes (vim-style: left/down/up/right)
prefix + z           # zoom pane to full screen (again to unzoom)
prefix + x           # close current pane
prefix + q           # flash pane numbers (press number to jump)

prefix + H/J/K/L     # resize pane (hold prefix, tap repeatedly)
```

### Copy mode (scrollback + search)

Your shell uses emacs keybindings. tmux copy mode uses vi keys.
They don't conflict — copy mode is a separate mode you enter explicitly.

```bash
prefix + [           # enter copy mode (or prefix + Escape)
prefix + ]           # paste from tmux buffer

# Inside copy mode:
/                    # search forward  (like vim)
?                    # search backward
n / N                # next / previous search result
v                    # begin selection
V                    # select whole line
y                    # yank (copy) → goes to system clipboard via tmux-yank
q / Escape           # exit copy mode

Ctrl+u / Ctrl+d      # half-page up / down
g / G                # jump to top / bottom of history
```

### Config

```bash
prefix + r           # reload ~/.tmux.conf without restarting tmux
prefix + I           # install new plugins (TPM)
prefix + U           # update plugins
```

### Session persistence (tmux-resurrect + tmux-continuum)

```bash
prefix + Ctrl+s      # manually save session (layout + running commands)
prefix + Ctrl+r      # manually restore last save

# Continuum auto-saves every 15 minutes and auto-restores on tmux start.
# After a reboot: just run `t home` and everything comes back.
```

---

## Claude Code + tmux: the productive setup

### Why this matters for tokens

Each time you start a new Claude Code session you start from scratch — no context,
no memory of your project. Claude has to re-read files, re-understand the codebase.
Every re-read costs tokens.

tmux lets you **keep one Claude Code session running all day** across:
- screen locks
- laptop sleep (with `wake` / `caffeinate`)
- closing and reopening Terminal
- brief SSH drops
- reboots (via tmux-resurrect)

The session persists. The context persists. You save tokens and time.

---

### Recommended layout for Claude Code work

```
┌──────────────────────────┬──────────────────────┐
│                          │                      │
│   pane 1: claude code    │   pane 2: terminal   │
│   (full height, left)    │   files, git, tests  │
│                          │                      │
│                          ├──────────────────────┤
│                          │   pane 3: logs /     │
│                          │   server output      │
└──────────────────────────┴──────────────────────┘
```

Set this up once:
```bash
tn claude                        # new session named "claude"
prefix + |                       # split vertically
prefix + l                       # move to right pane
prefix + -                       # split right pane horizontally
prefix + h                       # move back to left pane (claude)
```

Then save it:
```bash
prefix + Ctrl+s                  # saved — survives reboots
```

---

### Daily workflow

```bash
# Morning / start of work:
ta claude                        # attach — everything is exactly as you left it
                                 # Claude Code session in left pane still has context

# Before stepping away:
wake                             # keep Mac awake if on battery
Ctrl+Cmd+Q                       # lock screen
                                 # → Claude session on phone via remote still works

# When you come back:
uncafe                           # if on battery
                                 # Claude session in tmux still alive, no re-read needed

# If you had to reboot:
ta claude                        # tmux-continuum restores your layout
                                 # start Claude Code in left pane — minimal re-read
```

---

### Token-saving patterns

**Pattern 1: Don't restart Claude, switch context with tmux**

Instead of closing Claude and opening a new session for a different task:
```
prefix + c           # open a new window in same session
                     # do the other thing
prefix + 1           # come back to window 1 (Claude still running, context intact)
```

**Pattern 2: Read output without asking Claude**

Instead of asking Claude "what did that command output?" — run the command in
pane 2, scroll back with `prefix + [` and read it yourself. Only bring Claude in
when you actually need reasoning, not just to relay text.

**Pattern 3: Paste directly into Claude**

Run a command in pane 2, copy its output with `v` → `y` in copy mode,
switch to Claude pane and paste. Claude gets the real output, not a
description of the output. More accurate, fewer follow-up tokens.

**Pattern 4: Long-running tasks in background pane**

Start a build/test/server in pane 3. Work with Claude in pane 1.
You can watch the output without context switching apps or asking Claude
to run things again.

**Pattern 5: Zoom when reading**

`prefix + z` to zoom pane to full screen when you need to read a long
Claude response or a file. Unzoom to go back to split view.

---

## Quick reference card

```
PREFIX = Ctrl+b

SESSIONS          WINDOWS           PANES
──────────────    ──────────────    ──────────────────────
prefix+d detach   prefix+c new      prefix+| split right
prefix+s switch   prefix+n next     prefix+- split down
ta <n>  attach    prefix+p prev     prefix+h/j/k/l move
tn <n>  new       prefix+, rename   prefix+H/J/K/L resize
tl      list      prefix+w picker   prefix+z zoom toggle
                  prefix+1-9 jump   prefix+x close pane

COPY MODE (prefix+[)
──────────────────────────────────
v begin   V line   y yank   q quit
/ search  n next   Ctrl+u/d scroll
```

---

## Things that trip people up

**"My escape key is slow in vim/emacs inside tmux"**
→ Fixed. `escape-time 10` is set in your `.tmux.conf`.

**"I accidentally closed my terminal and lost everything"**
→ The tmux session is still running. Open a new terminal and run `t home`.
→ If you truly killed the server: tmux-continuum auto-saved 15min ago. Run `t home`
   and tmux-resurrect will restore it.

**"prefix + l conflicts with something"**
→ In tmux, `prefix + l` selects the pane to the right. In your shell (emacs mode),
   `Ctrl+l` clears the screen. These are different keys — no conflict.

**"The status bar colors look wrong"**
→ Make sure your terminal is set to use a font with Nerd Font glyphs
   (JetBrains Mono Nerd Font is already in your README).
→ Also check: Terminal → Settings → Profiles → set "Report terminal as: xterm-256color".

**"Auto-start tmux is opening tmux inside tmux"**
→ The `[[ -z "$TMUX" ]]` guard in `.zshrc` prevents this. If it happens,
   check that `$TMUX` isn't being unset somewhere in your config.
