#!/usr/bin/env bash
set -euo pipefail

# Universal launcher for customer sites via docker-compose
# Usage:
#   ./launch.sh up customer-a
#   ./launch.sh down customer-b
#   ./launch.sh restart customer-a
#   ./launch.sh logs customer-b
#   ./launch.sh proxy-up|proxy-down|proxy-logs

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITES_DIR="$ROOT_DIR/sites"
PROXY_DIR="$ROOT_DIR/proxy"

cmd=${1:-}
target=${2:-}

function usage() {
  echo "Usage: $0 <up|down|restart|logs|proxy-up|proxy-down|proxy-logs> <customer-name>"
  exit 1
}

function ensure_proxy_network() {
  # Create external network used by sites if it doesn't exist
  if ! docker network inspect traefik_proxy >/dev/null 2>&1; then
    echo "Creating external network 'traefik_proxy'"
    docker network create traefik_proxy >/dev/null
  fi
}

function run_proxy() {
  ensure_proxy_network
  pushd "$PROXY_DIR" >/dev/null
  case "$1" in
    up)
      # Ensure acme.json permissions are 644 per Traefik requirements
      mkdir -p letsencrypt
      touch letsencrypt/acme.json
      chmod 644 letsencrypt/acme.json || true
      docker compose up -d
      ;;
    down)
      docker compose down
      ;;
    logs)
      docker compose logs -f
      ;;
    *) usage ;;
  esac
  popd >/dev/null
}

function run_site() {
  local site="$1"
  local dir="$SITES_DIR/$site"
  if [[ ! -d "$dir" ]]; then
    echo "Site '$site' not found in $SITES_DIR" >&2
    exit 2
  fi
  if [[ ! -f "$dir/.env" ]]; then
    echo "Missing $dir/.env" >&2
    exit 2
  fi
  ensure_proxy_network
  pushd "$dir" >/dev/null
  case "$cmd" in
    up)
      docker compose --env-file .env up -d
      ;;
    down)
      docker compose --env-file .env down
      ;;
    restart)
      docker compose --env-file .env down
      docker compose --env-file .env up -d
      ;;
    logs)
      docker compose --env-file .env logs -f
      ;;
    *) usage ;;
  esac
  popd >/dev/null
}

if [[ -z "$cmd" ]]; then usage; fi

case "$cmd" in
  proxy-up)
    run_proxy up
    ;;
  proxy-down)
    run_proxy down
    ;;
  proxy-logs)
    run_proxy logs
    ;;
  up|down|restart|logs)
    [[ -n "$target" ]] || usage
    run_site "$target"
    ;;
  *)
    usage
    ;;
esac
