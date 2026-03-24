#!/bin/sh

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$INSTALL_DIR"

cp "$SCRIPT_DIR/claude_docker.sh" "$INSTALL_DIR/claude_docker"
chmod +x "$INSTALL_DIR/claude_docker"
echo "Installed claude_docker -> $INSTALL_DIR/claude_docker"

# Add to PATH if not already present
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    SHELL_RC="$HOME/.zshrc"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "Added $INSTALL_DIR to PATH in $SHELL_RC"
    echo "Run: source $SHELL_RC"
fi
