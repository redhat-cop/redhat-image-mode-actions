# AAP Quadlet Deployment

This directory contains Podman Quadlet configuration files for deploying Red Hat Ansible Automation Platform (AAP) 2.5 as individual containerized services managed by systemd.

## Overview

The deployment includes the following components:

### Core AAP Services
- **aap-controller**: Ansible Automation Platform Controller
- **aap-hub**: Automation Hub for content management  
- **aap-eda-controller**: Event-Driven Automation Controller
- **aap-eda-controller-ui**: EDA Controller Web UI
- **aap-hub-web**: Hub Web Interface
- **aap-gateway**: AAP Gateway service
- **aap-gateway-proxy**: Gateway Proxy service
- **aap-receptor**: Receptor mesh networking

### Infrastructure Services
- **aap-postgresql**: PostgreSQL database
- **aap-redis**: Redis cache
- **aap-pcp**: Performance Co-Pilot monitoring

### Execution Environments
- **aap-ee-minimal**: Minimal execution environment
- **aap-ee-supported**: Supported execution environment  
- **aap-de-supported**: Decision environment for EDA

### Networking
- **aap-network**: Dedicated container network (172.20.0.0/24)

## Prerequisites

1. **Podman 4.0+** with quadlet support
2. **systemd** for service management
3. **Red Hat registry access** - You need:
   - Red Hat customer portal account
   - Registry service account for `registry.redhat.io`
   - Valid AAP subscription

## Quick Start

Make sure all quadlet files are in the /etc/containers/systemd/ directory

## Access URLs

Once all services are running:

- **AAP Gateway**: https://localhost:443
- **Controller**: https://localhost:8443
- **Automation Hub**: https://localhost:5001
- **EDA Controller**: https://localhost:5000
- **EDA UI**: https://localhost:3000
- **Hub Web**: https://localhost:8002

Default credentials:
- Username: `admin`  
- Password: `redhat`

## Management Commands

The `manage-aap-quadlet.sh` script provides comprehensive management:

```bash
# Install quadlet files
./manage-aap-quadlet.sh install [user|system]

# Service management
./manage-aap-quadlet.sh start [user|system]
./manage-aap-quadlet.sh stop [user|system]
./manage-aap-quadlet.sh restart [user|system]

# Enable/disable services
./manage-aap-quadlet.sh enable [user|system]
./manage-aap-quadlet.sh disable [user|system]

# Check status
./manage-aap-quadlet.sh status [user|system]

# Clean up everything
./manage-aap-quadlet.sh cleanup [user|system]
```

## User vs System Mode

### User Mode (Default)
- Services run as the current user
- Files installed to `~/.config/containers/systemd/`
- Services managed with `systemctl --user`
- No root privileges required
- Services stop when user logs out (unless lingering is enabled)

### System Mode  
- Services run system-wide
- Files installed to `/etc/containers/systemd/`
- Services managed with `systemctl`
- Requires root/sudo privileges
- Services persist across user sessions

## Registry Authentication

Before deploying, authenticate with the Red Hat registry:

```bash
podman login registry.redhat.io
```

You'll need:
- Registry service account username (contains `|` character)
- Registry service account password

## Persistent Storage

The configuration creates named volumes for persistent data:

- `aap-controller-data`: Controller application data
- `aap-hub-data`: Hub content and artifacts
- `aap-postgresql-data`: Database storage
- `aap-redis-data`: Redis cache data
- And more...

To list all volumes:
```bash
podman volume ls | grep aap-
```

## Service Dependencies

Services start in the correct order automatically:

1. **Infrastructure**: Network → PostgreSQL → Redis
2. **Core Services**: Controller, Hub, EDA Controller  
3. **Web Interfaces**: Hub Web, EDA UI
4. **Gateway**: Gateway → Gateway Proxy
5. **Support**: Receptor, PCP

## Troubleshooting

### Check service logs:
```bash
journalctl --user -u aap-controller.service -f
```

### Check container status:
```bash
podman ps -a | grep aap-
```

### Verify network connectivity:
```bash
podman network inspect aap-network
```

### Debug container issues:
```bash
podman logs aap-controller
```

### Reset everything:
```bash
./manage-aap-quadlet.sh cleanup user
podman volume prune  # Remove unused volumes
podman network prune # Remove unused networks
```

## Customization

To customize the deployment:

1. **Edit quadlet files** in the `quadlet/` directory
2. **Modify environment variables** in the `.container` files
3. **Adjust resource limits** by adding `Memory=` and `CPUQuota=` directives
4. **Change network settings** in `aap-network.network`

Example resource limits:
```ini
[Container]
Memory=2G
CPUQuota=200%
```

## Security Considerations

- All services run as non-root users where possible
- Containers use SELinux labels (`:Z` volumes)
- Network isolation via dedicated bridge network
- Default passwords should be changed in production

## Performance Tuning

For production deployments:

1. **Increase resource limits** in quadlet files
2. **Use external PostgreSQL** for better performance
3. **Configure Redis persistence** if needed
4. **Add health checks** for better reliability
5. **Set up log rotation** for container logs

## Integration with Original Setup

This quadlet deployment can coexist with your existing bootc-based setup:

- Use different network ranges
- Use different volume names  
- Run on different ports
- Deploy in different systemd scopes (user vs system)

## Support

This configuration is based on:
- Red Hat AAP 2.5 containerized installation
- Podman Quadlet systemd generator
- Official Red Hat container images

For issues with:
- **AAP functionality**: Check Red Hat documentation
- **Container images**: Contact Red Hat support  
- **Quadlet configuration**: Check podman-systemd.unit(5) man page 