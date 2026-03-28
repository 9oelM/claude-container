#!/bin/zsh

# Usage: ./claude_docker.sh [launch|join]

case "$1" in
  launch)
    # This will prompt you to verify your account on platform.claude.com
    docker run -it --rm \
      -v "$(pwd)":/workspace \
      -w /workspace \
      ghcr.io/9oelm/claude-container \
      /bin/zsh
    ;;

  join)
    # Join an existing running container based on claude-container image
    CONTAINER_ID=$(docker ps -q -f ancestor=ghcr.io/9oelm/claude-container)
    if [ -z "$CONTAINER_ID" ]; then
      echo "No running container found for claude-container image."
      exit 1
    fi
    docker exec -it "$CONTAINER_ID" /bin/zsh
    ;;

  *)
    echo "Usage: $0 [launch|join]"
    echo "  launch  - Start a new claude-container Docker container"
    echo "  join    - Join an existing running claude-container"
    exit 1
    ;;
esac
