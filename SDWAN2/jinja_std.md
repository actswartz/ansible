# 🧪 Lab Book — Jinja2 Templates with One CSR1000v Router

## Lab 0 — Goal & Setup

**Goal**
Learn how to use Ansible with Jinja2 templates to automate configuration for a single Cisco CSR1000v router. By the end, you will know how to generate dynamic configuration files and push them safely.

**Environment:**

* One CSR1000v router with management IP **10.10.20.21X**
  *(replace X with your actual last digit — e.g., 10.10.20.211)*
* Python 3.8+ and Ansible installed on your control machine

### Step 1 — Create Working Folder

We’ll keep our project organized:

```bash
mkdir -p ~/ansible-jinja-csr/templates group_vars
cd ~/ansible-jinja-csr
```

`templates/` will hold Jinja2 files. `group_vars/` will hold variables shared across hosts.

### Step 2 — Install Ansible

Install Ansible if not already installed and check the version:

```bash
sudo apt update && sudo apt install ansible -y
ansible --version
```

### Step 3 — Create Inventory File

Inventory tells Ansible what devices to connect to and how.

`inventory.yml`:

```yaml
all:
  hosts:
    csr1:
      ansible_host: 10.10.20.21X
  vars:
    ansible_user: cisco
    ansible_password: cisco
    ansible_network_os: ios
```

* `csr1` is the name we’ll use to refer to the router.
* `ansible_network_os: ios` tells Ansible to use Cisco IOS modules.

---

## Lab 1 — Simple Banner

We’ll start with a very simple Jinja2 template that inserts the device hostname dynamically.

### Template

`templates/banner.j2`:

```jinja
!
banner motd ^
Welcome to {{ inventory_hostname }}
Authorized users only!
^
```

* `{{ inventory_hostname }}` gets replaced with the name defined in inventory (`csr1`).

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

* `ios_config` is the module that sends config lines to an IOS device.
* `src` points to the Jinja2 template file.

### Run

```bash
ansible-playbook -i inventory.yml banner.yml
```

**What happens:** Ansible connects to the router, renders the banner with the hostname, and pushes it.

**Expected Output:**

```
PLAY [Deploy Banner] ******************************************************************
TASK [Push banner using template] ****************************************************
changed: [csr1]
PLAY RECAP ***************************************************************************
csr1 : ok=1 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

---

## Lab 2 — VLAN Creation

Now we’ll define VLANs as data and generate config from that list.

### Variables

`group_vars/all.yml`:

```yaml
vlans:
  - { id: 10, name: USERS }
  - { id: 20, name: VOICE }
```

* We define VLAN numbers and names in YAML.

### Template

`templates/vlans.j2`:

```jinja
{% for vlan in vlans %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% endfor %}
```

* `{% for vlan in vlans %}` loops over each VLAN in the list.
* `{{ vlan.id }}` and `{{ vlan.name }}` substitute data from variables.

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

**What happens:** Template is filled with VLAN info and pushed to the router.

**Expected Output:**

```
PLAY [Create VLANs] *******************************************************************
TASK [ios_config] *********************************************************************
changed: [csr1] => (item={u'id': 10, u'name': u'USERS'})
changed: [csr1] => (item={u'id': 20, u'name': u'VOICE'})
PLAY RECAP ***************************************************************************
csr1 : ok=1 changed=1 unreachable=0 failed=0
```

---

## Lab 3 — Interfaces with Loops & Conditionals

We’ll create interface configs and use an `if` statement to optionally enable portfast.

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

* The `if` block only adds the portfast line when the variable is true.

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

**What happens:** Each interface gets rendered and pushed. Portfast appears only on those flagged true.

**Expected Output:**

```
PLAY [Configure Interfaces] ***********************************************************
TASK [ios_config] *********************************************************************
changed: [csr1] => (item={'name': 'Gig1', 'desc': 'USER-LAN', 'vlan': 10, 'portfast': True})
changed: [csr1] => (item={'name': 'Gig2', 'desc': 'VOICE-LAN', 'vlan': 20})
PLAY RECAP ***************************************************************************
csr1 : ok=1 changed=1 unreachable=0 failed=0
```

---

## Lab 4 — Test Dry Run (Check Mode)

Before making changes, see what would happen.

```bash
ansible-playbook -i inventory.yml interfaces.yml --check --diff
```

**What happens:** Ansible logs what would change but doesn’t configure the router.

**Expected Output:**

```
PLAY [Configure Interfaces] ***********************************************************
TASK [ios_config] *********************************************************************
changed: [csr1] => (item={'name': 'Gig1', 'desc': 'USER-LAN', 'vlan': 10, 'portfast': True})
changed: [csr1] => (item={'name': 'Gig2', 'desc': 'VOICE-LAN', 'vlan': 20})
PLAY RECAP ***************************************************************************
csr1 : ok=0 changed=2 unreachable=0 failed=0
```

✅ “changed” shows what would be applied, but the router stays untouched.

---

### Tips

* Only one router needed — adjust `ansible_host` if the IP changes.
* Use **Ansible Vault** to encrypt real passwords.
* `--check` + `--diff` is safest before production changes.
* Keep templates and variables organized for reuse.
