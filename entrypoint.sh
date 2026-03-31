#!/bin/bash
# Copy baked-in skills/config into mounted .claude without overwriting existing session data
cp -rn /home/vscode/.claude-baked/. /home/vscode/.claude/
exec "$@"
