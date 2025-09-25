
# 🧪 Lab Book — Jinja2 Templates with One CSR1000v Router (Updated)

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
      ansible_host: 10.10.20.211
  vars:
    ansible_user: cisco
    ansible_password: cisco
    ansible_network_os: ios
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco
    ansible_command_timeout: 60
```

* `csr1` is the name we’ll use to refer to the router.
* `ansible_network_os: ios` tells Ansible to use Cisco IOS modules.
* `ansible_become: yes` and `ansible_become_method: enable` are used to enter privileged (enable) mode.
* `ansible_become_password: cisco` provides the password for enable mode.
* `ansible_command_timeout: 60` increases the time Ansible will wait for a command to complete.

---

## Lab 1 — Simple Banner

We’ll start with a very simple Jinja2 template that inserts the device hostname dynamically.

### Template

`templates/banner.j2`:

```jinja
!
banner motd Q
Welcome to {{ inventory_hostname }}
Authorized users only!
Q
```

* `{{ inventory_hostname }}` gets replaced with the name defined in inventory (`csr1`).

### Playbook

`banner.yml`:

```yaml
---
- name: Deploy Banner
  hosts: all
  gather_facts: no
  connection: ansible.netcommon.network_cli
  become: yes
  become_method: enable
  tasks:
    - name: Display rendered banner
      debug:
        msg: "{{ lookup('template', 'templates/banner.j2').split('\n') }}"

    - name: Deploy Banner
      ios_config:
        src: templates/banner.j2
```

* `connection: ansible.netcommon.network_cli` tells Ansible to use the correct connection method for network devices.
* `ios_config` is the module that sends config lines to an IOS device.
* `src` points to the Jinja2 template file.

### Run

```bash
ansible-playbook -i inventory.yml banner.yml
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
  connection: ansible.netcommon.network_cli
  tasks:
    - ios_config:
        src: templates/vlans.j2
```

### Run

```bash
ansible-playbook -i inventory.yml vlans.yml
```

---

## Lab 3 — Interface IP Addressing

We’ll create interface configs with a description and an IP address.

### Variables

`group_vars/all.yml`:

```yaml
interfaces:
  - { name: Ethernet0/0, desc: WAN-Interface, ip_address: 192.168.1.1 255.255.255.0 }
  - { name: Ethernet0/1, desc: LAN-Interface, ip_address: 10.10.10.1 255.255.255.0 }
```

### Template

`templates/interfaces.j2`:

```jinja
{% for intf in interfaces %}
interface {{ intf.name }}
 description {{ intf.desc }}
 ip address {{ intf.ip_address }}
 no shutdown
{% endfor %}
```

### Playbook

`interfaces.yml`:

```yaml
---
- name: Configure Interfaces
  hosts: all
  gather_facts: no
  connection: ansible.netcommon.network_cli
  tasks:
    - name: Display rendered configuration
      debug:
        msg: "{{ lookup('template', 'templates/interfaces.j2').split('\n') }}"

    - name: Configure interfaces
      ios_config:
        src: templates/interfaces.j2
```

* The `debug` task will print the rendered configuration to the screen before applying it.

### Run

```bash
ansible-playbook -i inventory.yml interfaces.yml
```

---

## Lab 4 — Test Dry Run (Check Mode)

Before making changes, see what would happen.

```bash
ansible-playbook -i inventory.yml interfaces.yml --check --diff
```

---

## Lab 5 - Configure Hostname

This lab demonstrates how to set the device hostname.

### Variables

`group_vars/all.yml`:

```yaml
hostname: R2-Ansible
```

### Template

`templates/hostname.j2`:

```jinja
hostname {{ hostname }}
```

### Playbook

`hostname.yml`:

```yaml
---
- name: Configure Hostname
  hosts: all
  gather_facts: no
  connection: ansible.netcommon.network_cli
  become: yes
  become_method: enable
  tasks:
    - name: Display rendered hostname config
      debug:
        msg: "{{ lookup('template', 'templates/hostname.j2').split('\n') }}"

    - name: Set hostname
      ios_config:
        src: templates/hostname.j2
```

### Run

```bash
ansible-playbook -i inventory.yml hostname.yml
```

---

### Tips

* Only one router needed — adjust `ansible_host` if the IP changes.
* Use **Ansible Vault** to encrypt real passwords.
* `--check` + `--diff` is safest before production changes.
* Keep templates and variables organized for reuse.
