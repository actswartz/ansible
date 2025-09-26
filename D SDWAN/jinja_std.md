
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

### Step 4 - Lab Variables

`group_vars/all.yml`:

```yaml
hostname: R2-Ansible
users:
  - { name: admin1, password: password123, role: network-admin }
  - { name: user1, password: password456, role: network-operator }
interfaces:
  - { name: Ethernet0/0, desc: WAN-Interface, ip_address: 192.168.1.1 255.255.255.0 }
  - { name: Ethernet0/1, desc: LAN-Interface, ip_address: 10.10.10.1 255.255.255.0 }
```

---

## Lab 1 - Configure Hostname

This lab demonstrates how to set the device hostname.

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
./lab1.sh
```

---

## Lab 2 — User Creation

Now we’ll define users as data and generate config from that list.

### Template

`templates/users.j2`:

```jinja
{% for user in users %}
username {{ user.name }} privilege 15 secret {{ user.password }}
{% endfor %}
```

### Playbook

`users.yml`:

```yaml
---
- name: Create Users
  hosts: all
  gather_facts: no
  connection: ansible.netcommon.network_cli
  become: yes
  become_method: enable
  tasks:
    - name: Display rendered user configuration
      debug:
        msg: "{{ lookup('template', 'templates/users.j2').split('\n') }}"

    - name: Create users
      ios_config:
        src: templates/users.j2
```

### Run

```bash
./lab2.sh
```

---

## Lab 3 — Interface IP Addressing

We’ll create interface configs with a description and an IP address.

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

### Run

```bash
./lab3.sh
```

---

## Lab 4 — Test Dry Run (Check Mode)

Before making changes, see what would happen.

```bash
./lab4.sh
```

---

### Tips

* Only one router needed — adjust `ansible_host` if the IP changes.
* Use **Ansible Vault** to encrypt real passwords.
* `--check` + `--diff` is safest before production changes.
* Keep templates and variables organized for reuse.
