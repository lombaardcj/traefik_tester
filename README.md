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
chmod 644 proxy/letsencrypt/acme.json
./launch.sh proxy-up
```

2. Bring up an example customer:

```bash
./launch.sh up customer-a
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

# traefik_tester
Test multi customer hosting from vanilla docker compose and traefik
