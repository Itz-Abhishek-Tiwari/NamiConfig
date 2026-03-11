#!/bin/bash

# --- System Optimization Script for Development ---
# Focus: React, React Native, and Django
# Optimizes: File watching (Watchman) and inotify limits.

set -e

echo "🚀 Starting system optimization..."

# 1. Optimize inotify limits (Essential for large JS projects)
# Current max_user_watches is 524288, which is good, but let's ensure it's permanent and standard across instances.
LIMITS_FILE="/etc/sysctl.d/99-dev-optimizations.conf"

if [ ! -f "$LIMITS_FILE" ]; then
    echo "🔧 Setting permanent inotify limits..."
    echo "fs.inotify.max_user_watches=524288" | sudo tee "$LIMITS_FILE" > /dev/null
    echo "fs.inotify.max_user_instances=1024" | sudo tee -a "$LIMITS_FILE" > /dev/null
    echo "fs.inotify.max_queued_events=16384" | sudo tee -a "$LIMITS_FILE" > /dev/null
    sudo sysctl --system > /dev/null
    echo "✅ Inotify limits applied permanently."
else
    echo "✅ Inotify limits already configured in $LIMITS_FILE."
fi

# 2. Final verification
echo -e "\n--- Verification ---"
echo "Inotify max_user_watches: $(cat /proc/sys/fs/inotify/max_user_watches)"

echo -e "\n✨ System is now optimized for React/Django development!"
echo "Note: Since you use a physical phone for testing, your 8GB RAM should be sufficient."
