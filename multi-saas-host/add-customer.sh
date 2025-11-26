#!/usr/bin/env bash
set -euo pipefail

# Create a new customer directory from the template
# Usage: ./add-customer.sh customer-name domain.example.com

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$ROOT_DIR/sites/new-customer-template"
SITES_DIR="$ROOT_DIR/sites"

name=${1:-}
domain=${2:-}

if [[ -z "$name" || -z "$domain" ]]; then
  echo "Usage: $0 <customer-name> <domain>" >&2
  exit 1
fi

dest="$SITES_DIR/$name"
if [[ -d "$dest" ]]; then
  echo "Destination '$dest' already exists" >&2
  exit 2
fi

mkdir -p "$dest/certs"
cp "$TEMPLATE_DIR/docker-compose.yml" "$dest/docker-compose.yml"
cp "$TEMPLATE_DIR/docker-compose.dev.yml" "$dest/docker-compose.dev.yml"
cp "$TEMPLATE_DIR/docker-compose.prod.yml" "$dest/docker-compose.prod.yml"
mkdir -p "$dest/node"
cp "$TEMPLATE_DIR/node/Dockerfile" "$dest/node/Dockerfile"
cp "$TEMPLATE_DIR/node/app.js" "$dest/node/app.js"

cat > "$dest/.env" <<EOF
COMPOSE_PROJECT_NAME=$name
DOMAIN=$domain
HOST_PORT_HTTPS=
EOF

echo "Customer '$name' created at $dest"
echo "Edit $dest/.env if needed, then run:"
echo "  $ROOT_DIR/launch.sh up $name" 
echo "  # for local dev (HTTP only): $ROOT_DIR/launch.sh up $name --dev"
