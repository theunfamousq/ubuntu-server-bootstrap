# Ubuntu Server Bootstrap

Automated, secure, and reproducible bootstrap for Ubuntu servers using Ansible

## Overview

This project provides a compact set of Ansible playbooks and roles to **bootstrap, harden, and configure an Ubuntu server**. It covers the lifecycle from initial user bootstrap to SSH hardening, firewall setup, fail2ban, automatic updates, Docker installation, and system finalization.

It was originally created for an OVH VPS, but it does not depend on OVH APIs or provider-specific features. It should work with any Ubuntu >= 22.04 server reachable over SSH, including cloud VPS instances, bare-metal servers, and self-hosted virtual machines.

## Project Purpose

- **Automate**: Eliminate manual setup by automating every step with Ansible.
- **Harden**: Apply best-practice security measures (SSH hardening, firewall, fail2ban, etc.).
- **Modernize**: Set up Docker for containerized workloads.
- **Finalize**: Transition to a secure SSH authentication strategy.
- **Idempotent**: Safely re-run playbooks without unwanted side effects.

## Prerequisites

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your local machine
- Python installed on the target server (usually pre-installed on Ubuntu cloud images)
- SSH access to the target server (initial root or provider image user access)
- Properly configured **Ansible inventory** file with your server details
- SSH key(s) for provisioning

## Features

- **User Bootstrap**: Create and configure a non-root admin user for ongoing management
- **SSH Hardening**: Configure secure SSH settings, disable password/root login, enforce key-based auth
- **Firewall**: Set up and enable UFW (Uncomplicated Firewall) with strict rules
- **Fail2ban**: Protect against brute-force attacks with fail2ban
- **Automatic Updates**: Enable unattended security updates
- **Docker Installation**: Optionally install and configure Docker (and Compose) for container workloads
- **Finalization**: Optionally disable the initial provisioning user
- **Idempotency**: All tasks are safe to re-run, making updates and maintenance easy

## Project Structure

```tree
.
├── site.yml              # Main Ansible playbook
├── ansible.cfg           # Local Ansible defaults
├── requirements.yml      # Required Ansible collections
├── template.inventory.ini # Inventory template
├── inventory.ini         # Your ignored local inventory file
├── Makefile              # Common local commands
├── group_vars/           # Group-wide variable definitions
├── roles/
│   ├── bootstrap/        # Initial user and basic setup
│   ├── security/         # SSH, firewall, fail2ban, updates
│   ├── docker/           # Docker and Compose installation
│   └── finalize/         # Final hardening and cleanup
```

## Usage

1. **Clone this repository:**

    ```bash
    git clone https://github.com/theunfamousq/ubuntu-server-bootstrap.git
    cd ubuntu-server-bootstrap
    ```

2. **Configure your inventory:**
    - Copy `template.inventory.ini` to `inventory.ini`.
    - For the first run, use the provider's initial SSH user and port. On many Ubuntu cloud images this is `ansible_user=ubuntu` and `ansible_port=22`, but some providers use `root`, `admin`, or another image-specific user.

3. **Customize variables:**
    - Copy `group_vars/template.all.yml` to `group_vars/all.yml`.
    - Set `admin_user`, `admin_ssh_pubkeys`, `ssh_port`, `open_ports`, Docker options, and finalization options.
    - `group_vars/all.yml` and `inventory.ini` are intentionally ignored by Git.
    - Set `docker_enabled: false` if you only want a hardened Ubuntu server without Docker.

4. **Install required Ansible collections:**

    ```bash
    make install
    ```

    If the local virtual environment is missing or broken, rebuild it first:

    ```bash
    make reset-venv
    make install
    ```

5. **Validate the playbook:**

    ```bash
    make syntax-check
    ```

6. **Preview changes without applying them:**

    ```bash
    make dry-run
    ```

7. **Run the playbook for the first time:**

    ```bash
    make run
    ```

8. **Update the inventory for future runs:**
    - After finalization, the initial user can be disabled and SSH can move to `ssh_port`.
    - Update `inventory.ini` to use the configured admin user and SSH port, for example:

      ```ini
      [ubuntu_servers]
      server1 ansible_host=your.server.example ansible_user=<admin_user> ansible_port=<ssh_port> ansible_ssh_private_key_file=~/.ssh/id_ed25519 ansible_python_interpreter=/usr/bin/python3
      ```

9. **Use tags for targeted runs:**
    - You can rerun specific roles using tags, e.g.:

      ```bash
      ansible-playbook -i inventory.ini site.yml --tags "docker"
      ```

## First Run vs Subsequent Runs

The first run usually connects with the provider image user, such as `ubuntu`, `root`, or `admin`, on port `22`. During that run, the playbook creates `admin_user`, installs the configured SSH keys, hardens SSH, opens `ssh_port`, verifies that the new port is reachable, and can disable the initial provisioning user.

After a successful first run, update `inventory.ini` to connect with `admin_user` on `ssh_port`. Future runs should use that hardened access path. If you later change `ssh_port`, keep console access to the server available while applying the change.

Useful security variables:

```yaml
ssh_allow_users:
  - "{{ admin_user }}"
unattended_upgrades_automatic_reboot: true
unattended_upgrades_reboot_time: "04:30"
docker_enabled: true
```

## Development & Contributions

Contributions, bug reports, and suggestions are welcome! To contribute:

- Fork the repository and create a feature branch
- Follow existing code/role structure and best practices
- Submit a pull request with a clear description

If you find an issue or need help, please open a [GitHub Issue](https://github.com/theunfamousq/ubuntu-server-bootstrap/issues).

## License

This project is licensed under the [MIT License](LICENSE).

## Author

Quentin ROUSSEY
