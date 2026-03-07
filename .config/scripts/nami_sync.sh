#!/usr/bin/env bash
# ╔══════════════════════════════════════╗
# ║  nami_sync.sh — Sync NamiConfig to  ║
# ║  GitHub with rich notifications      ║
# ╚══════════════════════════════════════╝

REPO_DIR="$HOME/NamiConfig"
SYNC_ID="nami-git-sync"
APP="NamiSync"

notify() {
    local msg="$1"
    local icon="${2:-folder-sync}"
    notify-send -a "$APP" -i "$icon" \
        -h "string:x-canonical-private-synchronous:$SYNC_ID" \
        "$msg"
}

cd "$REPO_DIR" || {
    notify "❌ Repo not found: $REPO_DIR" "dialog-error"
    exit 1
}

# ── Check if inside a git repo ──────────────────
if ! git rev-parse --git-dir &>/dev/null; then
    notify "❌ Not a git repository" "dialog-error"
    exit 1
fi

# ── Check for remote ────────────────────────────
if ! git remote get-url origin &>/dev/null; then
    notify "❌ No remote 'origin' configured" "dialog-error"
    exit 1
fi

# ── Check for changes ───────────────────────────
CHANGED=$(git status --porcelain)
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)

if [[ -z "$CHANGED" && "$AHEAD" -eq 0 ]]; then
    notify "✅ Already up to date — nothing to push" "emblem-default"
    exit 0
fi

notify "🔄 Syncing dotfiles to GitHub…" "folder-sync"

# ── Stage all changes ───────────────────────────
if ! git add -A 2>&1; then
    notify "❌ git add failed" "dialog-error"
    exit 1
fi

# ── Commit ──────────────────────────────────────
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
FILES_CHANGED=$(git diff --cached --stat | tail -1)
COMMIT_MSG="nami: sync dotfiles [$TIMESTAMP]"

if git diff --cached --quiet; then
    # Nothing staged (all files were already tracked & unmodified)
    :
else
    if ! git commit -m "$COMMIT_MSG" &>/dev/null; then
        notify "❌ git commit failed" "dialog-error"
        exit 1
    fi
fi

# ── Push ────────────────────────────────────────
if ! git push origin HEAD 2>&1; then
    notify "❌ git push failed — check network & credentials" "dialog-error"
    exit 1
fi

PUSHED=$(git rev-list --count @{u}..HEAD@{1} 2>/dev/null || echo "?")
notify "✅ Synced to GitHub  ·  $FILES_CHANGED" "emblem-default"
