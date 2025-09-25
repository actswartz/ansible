

# 🧪 Lab Book — Jinja2 Templates with One CSR1000v Router

---

## Lab 0 — Goal & Setup

**Goal**
Use a single Cisco CSR1000v router to learn Jinja2 templating with Ansible.

**Environment:**

* One CSR1000v router with management IP **10.10.20.21X**
  *(replace X with your actual last digit — e.g., 10.10.20.211)*
* Python 3.8+ and Ansible installed on your control machine

---

### Step 1 — Create Working Folder

```bash
mkdir -p ~/ansible-jinja-csr/templates group_vars
cd ~/ansible-jinja-csr
```

### Step 2 — Install Ansible

```bash
sudo apt update && sudo apt install ansible -y
ansible --version
```

### Step 3 — Create Inventory File

`inventory.yml`:

```yaml
all:
  hosts:
    csr1:
      ansible_host: 10.10.20.21X
  vars:
    ansible_user: admin
    ansible_password: Cisco123
    ansible_network_os: ios
```

✅ `csr1` is your single router.

---

## Lab 1 — Simple Banner

### Template

`templates/banner.j2`:

```jinja
!
banner motd ^
Welcome to {{ inventory_hostname }}
Authorized users only!
^
```

### Playbook

`banner.yml`:

```yaml
---
- name: Deploy Banner
  hosts: all
  gather_facts: no
  tasks:
    - ios_config:
        src: templates/banner.j2
```

### Run

```bash
ansible-playbook -i inventory.yml banner.yml
```

---

## Lab 2 — VLAN Creation

### Variables

`group_vars/all.yml`:

```yaml
vlans:
  - { id: 10, name: USERS }
  - { id: 20, name: VOICE }
```

### Template

`templates/vlans.j2`:

```jinja
{% for vlan in vlans %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% endfor %}
```

### Playbook

`vlans.yml`:

```yaml
---
- name: Create VLANs
  hosts: all
  gather_facts: no
  tasks:
    - ios_config:
        src: templates/vlans.j2
```

### Run

```bash
ansible-playbook -i inventory.yml vlans.yml
```

---

## Lab 3 — Interfaces with Loops & Conditionals

### Variables

`group_vars/all.yml`:

```yaml
interfaces:
  - { name: Gig1, desc: USER-LAN, vlan: 10, portfast: true }
  - { name: Gig2, desc: VOICE-LAN, vlan: 20 }
```

### Template

`templates/interfaces.j2`:

```jinja
{% for intf in interfaces %}
interface {{ intf.name }}
 description {{ intf.desc }}
 switchport access vlan {{ intf.vlan }}
{% if intf.portfast %}
 spanning-tree portfast
{% endif %}
{% endfor %}
```

### Playbook

`interfaces.yml`:

```yaml
---
- name: Configure Interfaces
  hosts: all
  gather_facts: no
  tasks:
    - ios_config:
        src: templates/interfaces.j2
```

### Run

```bash
ansible-playbook -i inventory.yml interfaces.yml
```

---

## Lab 4 — Test Dry Run (Check Mode)

Before pushing any config, check changes:

```bash
ansible-playbook -i inventory.yml interfaces.yml --check --diff
```

✅ Shows what will change but doesn’t touch the router.

---

### Tips

* Only one router needed — adjust `ansible_host` if the IP changes.
* Put sensitive passwords in **Ansible Vault** for security.
* Use `--check` first to preview.
* Keep templates under `templates/` and variables in `group_vars/`.

---
