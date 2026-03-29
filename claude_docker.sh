#!/bin/zsh

# Usage: ./claude_docker.sh [launch|join] [-p PORT[:PORT]...]
# Examples:
#   ./claude_docker.sh launch -p 3000 -p 8080:8080
#   ./claude_docker.sh launch -p 5432:5432 -p 6379:6379

ACTION="$1"
shift 2>/dev/null

# Collect -p flags for port mappings
PORT_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p)
      PORT_ARGS+=("-p" "$2")
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

case "$ACTION" in
  launch)
    # Persist Claude session data (~/.claude) across container restarts
    CLAUDE_DATA_DIR="${HOME}/.claude-container-data"
    mkdir -p "$CLAUDE_DATA_DIR"

    # Always pull latest image
    docker pull ghcr.io/9oelm/claude-container

    # This will prompt you to verify your account on platform.claude.com
    docker run -it --rm \
      "${PORT_ARGS[@]}" \
      -v "$(pwd)":/workspace \
      -v "$CLAUDE_DATA_DIR":/home/vscode/.claude \
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

  scrap)
    # Stop and remove all running claude-container containers
    CONTAINER_IDS=$(docker ps -q -f ancestor=ghcr.io/9oelm/claude-container)
    if [ -z "$CONTAINER_IDS" ]; then
      echo "No running claude-container containers found."
      exit 0
    fi
    echo "$CONTAINER_IDS" | xargs docker rm -f
    echo "All claude-container containers have been removed."
    ;;

  *)
    echo "Usage: $0 [launch|join|scrap] [-p PORT[:PORT]...]"
    echo "  launch  - Start a new claude-container Docker container"
    echo "  join    - Join an existing running claude-container"
    echo "  scrap   - Stop and remove all claude-container containers"
    echo "  -p      - Publish a container port (e.g. -p 3000:3000)"
    exit 1
    ;;
esac
