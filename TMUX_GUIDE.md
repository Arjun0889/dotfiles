# tmux — Learning Guide & Claude Code Productivity

---

## What is tmux?

Think of your terminal the way you think of a browser.

| Browser | tmux |
|---|---|
| The browser app | tmux server (runs invisibly in background) |
| Browser window | **Session** — a named workspace (e.g. "home", "work", "claude") |
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
└── session: "home"          ← your base camp, always running
│   ├── window 1: "zsh"
│   │   ├── pane (left):   general shell
│   │   └── pane (right):  git / logs
│   └── window 2: "scratch"
└── session: "work"
    └── window 1: "api"
        ├── pane (left):   claude code
        ├── pane (top-right): files / git
        └── pane (bottom-right): server / logs
```

---

## Your prefix key

Everything in tmux starts with the **prefix**: `Ctrl+b`

Press it, release it, then press the command key.
It does not conflict with your emacs `Ctrl+a` (beginning-of-line) in the shell.

Think of it like the `Cmd` key on Mac — it's the modifier that tells tmux
"this next key is for you, not the shell."

---

## Daily commands — commit these to muscle memory

### Sessions

```bash
# t <name> — the one command you need for sessions
# Works from anywhere: inside tmux or outside
#   Session exists?     → switch to it
#   Doesn't exist?      → create it, then switch
t             # go to "home" session
t work        # go to "work" session
t claude      # go to "claude" session

tl            # list all running sessions
tk <name>     # kill a session by name (tk work, tk claude)
              # tk alone does nothing — always needs a name

# Inside tmux:
Ctrl+b d      # detach  (session keeps running — safe to close terminal)
Ctrl+b s      # interactive session picker — see all sessions, arrow keys + Enter
Ctrl+b $      # rename current session
Ctrl+b (      # switch to previous session
Ctrl+b )      # switch to next session
```

### Windows (tabs)

```bash
Ctrl+b c      # new window (opens in current directory)
Ctrl+b n      # next window
Ctrl+b p      # previous window
Ctrl+b 1-9    # jump directly to window by number
Ctrl+b ,      # rename current window
Ctrl+b &      # close current window (asks for confirmation)
Ctrl+b w      # visual window picker
```

### Panes (splits)

```bash
Ctrl+b |      # split vertically   → two panes side by side
Ctrl+b -      # split horizontally → pane above and below

Ctrl+b h/j/k/l   # move between panes (left/down/up/right)
Ctrl+b z         # zoom pane to full screen (again to unzoom)
Ctrl+b x         # close current pane
Ctrl+b q         # flash pane numbers (press number to jump)

Ctrl+b H/J/K/L   # resize pane (hold prefix, tap repeatedly)
```

### Killing things — what dies and what survives

```bash
tk <name>     # kill entire session (all windows + panes inside it)
Ctrl+b &      # kill current window (all panes inside it)
exit          # close current pane only
              # last pane closing → window closes
              # last window closing → session ends
```

### Copy mode (scrollback + search)

Your shell uses emacs keybindings. tmux copy mode uses vi keys.
They don't conflict — copy mode is a separate mode you enter explicitly.

```bash
Ctrl+b [      # enter copy mode (scroll up through terminal history)
Ctrl+b ]      # paste from tmux buffer

# Inside copy mode:
/             # search forward  (like vim)
?             # search backward
n / N         # next / previous search result
v             # begin selection
V             # select whole line
y             # yank (copy) → goes to system clipboard via tmux-yank
q / Escape    # exit copy mode

Ctrl+u / Ctrl+d   # half-page up / down
g / G             # jump to top / bottom of history
```

### Config

```bash
Ctrl+b r      # reload ~/.tmux.conf without restarting tmux
Ctrl+b I      # install new plugins (TPM)
Ctrl+b U      # update plugins
```

### Session persistence (tmux-resurrect + tmux-continuum)

```bash
Ctrl+b Ctrl+s   # manually save session (layout + running commands)
Ctrl+b Ctrl+r   # manually restore last save

# Continuum auto-saves every 15 minutes and auto-restores on tmux start.
# After a reboot: open terminal → auto-lands in "home" → layout restored.
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
t claude          # create/switch to "claude" session
Ctrl+b |          # split vertically
Ctrl+b l          # move to right pane
Ctrl+b -          # split right pane horizontally
Ctrl+b h          # move back to left pane
Ctrl+b Ctrl+s     # save — survives reboots
```

---

### Daily workflow

```bash
# Morning / start of work:
# Open Terminal → auto-lands in "home"
t claude          # switch to claude session — layout restored, context intact

# Before stepping away:
wake              # keep Mac awake if on battery
Ctrl+Cmd+Q        # lock screen
                  # → Claude session on phone via remote still works

# When you come back:
uncafe            # if on battery
                  # Claude session in tmux still alive, no re-read needed

# If you had to reboot:
# Open Terminal → auto-lands in "home" → continuum restores layout
t claude          # switch to claude session
```

---

### Token-saving patterns

**Pattern 1: Don't restart Claude, switch context with tmux**

Instead of closing Claude and opening a new session for a different task:
```
Ctrl+b c      # open a new window in same session
              # do the other thing
Ctrl+b 1      # come back to window 1 (Claude still running, context intact)
```

**Pattern 2: Read output without asking Claude**

Instead of asking Claude "what did that command output?" — run the command in
pane 2, scroll back with `Ctrl+b [` and read it yourself. Only bring Claude in
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

`Ctrl+b z` to zoom pane to full screen when you need to read a long
Claude response or a file. Same keys to unzoom back to split view.

---

## Quick reference card

```
PREFIX = Ctrl+b

SESSIONS                    WINDOWS              PANES
──────────────────────────  ─────────────────    ──────────────────────
t <name>  switch/create     Ctrl+b c  new        Ctrl+b |  split right
t         go to "home"      Ctrl+b n  next        Ctrl+b -  split down
tl        list              Ctrl+b p  prev        Ctrl+b hjkl  move
tk <name> kill session      Ctrl+b ,  rename      Ctrl+b HJKL  resize
Ctrl+b d  detach            Ctrl+b w  picker      Ctrl+b z  zoom toggle
Ctrl+b s  session picker    Ctrl+b 1-9  jump      Ctrl+b x  close pane
Ctrl+b $  rename session    Ctrl+b &  kill window

COPY MODE (Ctrl+b [)
──────────────────────────────────
v begin   V line   y yank   q quit
/ search  n next   Ctrl+u/d scroll
```

---

## Things that trip people up

**"sessions should be nested with care, unset $TMUX to force"**
→ You ran `tmux` or an old attach command from inside tmux. Use `t <name>` instead —
  it detects whether you're inside tmux and uses switch-client automatically.

**"I accidentally closed my terminal and lost everything"**
→ The tmux session is still running. Open a new terminal (auto-lands in "home").
→ Use `Ctrl+b s` to switch to your other session.
→ If you truly killed the server: continuum auto-saved 15min ago. Run `t home`
  and tmux-resurrect will restore it.

**"My escape key is slow in vim/emacs inside tmux"**
→ Fixed. `escape-time 10` is set in your `.tmux.conf`.

**"tk without a name does nothing"**
→ Correct — `tk` needs a session name: `tk work`, `tk claude`. Use `tl` first
  to see what sessions are running, then kill by name.

**"prefix + l conflicts with something"**
→ In tmux, `Ctrl+b l` moves to the right pane. In your shell (emacs mode),
  `Ctrl+l` clears the screen. Different key combinations — no conflict.

**"The status bar colors look wrong"**
→ Make sure your terminal uses JetBrains Mono Nerd Font (see README).
→ Terminal → Settings → Profiles → set "Report terminal as: xterm-256color".
