## Multi SaaS Host Structure

This repository includes a sample multi-tenant hosting setup using Traefik + Docker Compose.

Structure created under `multi-saas-host/`:

- `proxy/`: Single Traefik instance (ports 80/443) with Let's Encrypt.
- `sites/`: One folder per customer, each with its own `.env` and `docker-compose.yml`.
- `launch.sh`: Universal script to manage proxy and customer sites.
- `add-customer.sh`: Helper to scaffold new customers from the template.

### Quick Start

1. Start proxy (Traefik):

```bash
cd multi-saas-host
chmod +x launch.sh add-customer.sh
chmod 600 proxy/letsencrypt/acme.json
./launch.sh proxy-up
```
### Traefik Dashboard (Dev)

- The proxy exposes the dashboard at `http://localhost:8080` with `--api.insecure=true` and `--api.dashboard=true`.
- Use this to inspect routers, services, and middlewares during local development.


2. Bring up example customers (choose dev or prod):

Dev (HTTP-only, for local testing via /etc/hosts):

```bash
./launch.sh up customer-a --dev
./launch.sh up customer-b --dev
```

Prod (HTTPS with Let’s Encrypt):

```bash
./launch.sh up customer-a
./launch.sh up customer-b
```

3. Add a new customer:

```bash
./add-customer.sh customer-c customer-c.example.com
./launch.sh up customer-c
```

### Notes

- Customer compose files use `env_file: .env` and Traefik labels to route based on `DOMAIN`.
- Sites attach to external network `traefik_proxy` shared with the proxy.
- Leave `HOST_PORT_HTTPS` empty to avoid host port binding; Traefik handles routing.
- Ensure DNS points `DOMAIN` to the server running Traefik.

### Local Dev (HTTP-only)

- Map dev domains in `/etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 customer-a.example.com" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 customer-b.example.com" >> /etc/hosts'
```

- Start customers using the dev override (no TLS/LE):

```bash
cd multi-saas-host
./launch.sh up customer-a --dev
./launch.sh up customer-b --dev
```

- Visit `http://customer-a.example.com` and `http://customer-b.example.com`.

To return to HTTPS with Let’s Encrypt, omit `--dev`:

```bash
./launch.sh restart customer-a
```

### Shutdown and Cleanup

- Stop proxy:

```bash
cd multi-saas-host
./launch.sh proxy-down
```

- Stop sites (dev or prod):

```bash
# Dev stacks
./launch.sh down customer-a --dev
./launch.sh down customer-b --dev

# Prod stacks
./launch.sh down customer-a
./launch.sh down customer-b
```

- Remove orphan containers if needed:

```bash
docker compose ls
docker ps --format '{{.Names}} {{.Status}}'
```

# traefik_tester
Test multi customer hosting from vanilla docker compose and traefik
