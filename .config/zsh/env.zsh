# ── Environment Variables ──────────────────────
export PATH="$HOME/.local/bin:$PATH"
export NODE_ENV="development"
export QT_STYLE_OVERRIDE="qt5ct"
export XDG_CURRENT_DESKTOP="Hyprland"
export DESKTOP_SESSION="hyprland"
export EDITOR="nvim"

# Java & Android
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export ANDROID_HOME="$HOME/Android"
export ANDROID_SDK_ROOT="$HOME/Android"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$PATH:$(go env GOPATH 2>/dev/null || echo $HOME/go)/bin"
