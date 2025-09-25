

# 🧪 Lab Book — Learning Jinja2 Templates with Ansible

---

## Lab 0 — Goal & Setup

### 🎯 Goal

Learn how to build **dynamic network configurations** using Jinja2 templates inside Ansible. By the end you will know how to:

* Create and organize project files
* Build **templates** that render values from variables
* Use **loops** and **conditionals**
* Generate configurations for many devices quickly
* Send configurations to Cisco devices or to Catalyst Center templates

---

### 🧰 Why Jinja2?

* **Dynamic** — Replace hardcoded values with variables.
* **Reusable** — One template can configure many devices.
* **Readable** — Network engineers can understand YAML and Jinja2 easily.

---

### 🛠 Environment Setup

1. Create a folder for the labs:

```bash
mkdir -p ~/ansible-jinja-labs/templates group_vars
cd ~/ansible-jinja-labs
```

2. Install Ansible:

```bash
sudo apt update && sudo apt install ansible -y
ansible --version
```

> This verifies Ansible is ready to use.

3. Create your inventory file — this defines your lab devices:

`inventory.yml`

```yaml
all:
  hosts:
    switch1:
      ansible_host: 192.168.56.11
    switch2:
      ansible_host: 192.168.56.12
  vars:
    ansible_user: admin
    ansible_password: Cisco123
    ansible_network_os: ios
```

> **`ansible_network_os: ios`** tells Ansible these are Cisco IOS devices.

---

## Lab 1 — Your First Template (Banners)

### 🧠 Concept

A banner is a simple test of templating. We’ll insert each device’s hostname dynamically.

### Steps

1. **Template**

Create `templates/banner.j2`:

```jinja
!
banner motd ^
Welcome to {{ inventory_hostname }}
Authorized users only!
^
```

* `{{ inventory_hostname }}` = name from inventory (e.g., switch1).

2. **Playbook**

`banner.yml`:

```yaml
---
- name: Deploy Banner
  hosts: all
  gather_facts: no
  tasks:
    - name: Push banner using template
      ios_config:
        src: templates/banner.j2
```

3. **Run**

```bash
ansible-playbook -i inventory.yml banner.yml
```

✅ Each device shows its own hostname in the banner.

---

## Lab 2 — Loops to Build Interfaces

### 🧠 Concept

Use a list of interfaces and loop through them to generate config.

1. **Variables**

`group_vars/all.yml`:

```yaml
interfaces:
  - { name: Gig1/0/1, desc: User1, vlan: 10 }
  - { name: Gig1/0/2, desc: User2, vlan: 20 }
```

* `interfaces` is a list of dictionaries. Each has a name, description, VLAN.

2. **Template**

`templates/interfaces.j2`:

```jinja
{% for intf in interfaces %}
interface {{ intf.name }}
 description {{ intf.desc }}
 switchport access vlan {{ intf.vlan }}
 spanning-tree portfast
{% endfor %}
```

* `{% for %}` loops through each item in the list.

3. **Playbook**

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

4. **Run**

```bash
ansible-playbook -i inventory.yml interfaces.yml
```

✅ All interfaces defined in the list get configured.

---

## Lab 3 — Add Logic with Conditionals

### 🧠 Concept

Only add certain lines if a variable is true.

1. **Variables**

`group_vars/all.yml`:

```yaml
interfaces:
  - { name: Gig1/0/3, desc: HR-PC, vlan: 30, portfast: true }
  - { name: Gig1/0/4, desc: Camera, vlan: 40 }
```

2. **Template**

`templates/intf_conditional.j2`:

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

* `if intf.portfast` means only those with portfast true will get the line.

3. **Playbook**

`intf_conditional.yml`:

```yaml
---
- name: Configure Conditional Interfaces
  hosts: all
  gather_facts: no
  tasks:
    - ios_config:
        src: templates/intf_conditional.j2
```

4. **Run**

```bash
ansible-playbook -i inventory.yml intf_conditional.yml
```

---

## Lab 4 — Building VLAN Configs

### 🧠 Concept

Generate many VLANs from a list.

1. **Variables**

`group_vars/all.yml`:

```yaml
vlans:
  - { id: 10, name: USERS }
  - { id: 20, name: VOICE }
  - { id: 30, name: CAMERAS }
```

2. **Template**

`templates/vlans.j2`:

```jinja
{% for vlan in vlans %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% endfor %}
```

3. **Playbook**

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

4. **Run**

```bash
ansible-playbook -i inventory.yml vlans.yml
```

✅ Each VLAN gets created with its name.

---

## Lab 5 — Generate Catalyst Center Template

### 🧠 Concept

Use Jinja2 to dynamically build Catalyst Center (DNA Center) templates.

1. **Variables**

`group_vars/all.yml`:

```yaml
vlans:
  - { id: 10, ip: 192.168.10.1 }
  - { id: 20, ip: 192.168.20.1 }
```

2. **Template**

`templates/vlan_template.j2`:

```jinja
{% for vlan in vlans %}
interface vlan {{ vlan.id }}
 ip address {{ vlan.ip }} 255.255.255.0
 no shut
{% endfor %}
```

3. **Playbook**

`create_cc_template.yml`:

```yaml
---
- name: Create VLAN Template in Catalyst Center
  hosts: localhost
  collections:
    - cisco.dnac
  vars:
    dnac_host: "10.10.20.5"
    dnac_username: "admin"
    dnac_password: "C1sco12345"
  tasks:
    - dnac_template_create:
        dnac_host: "{{ dnac_host }}"
        dnac_username: "{{ dnac_username }}"
        dnac_password: "{{ dnac_password }}"
        project_name: "Campus_VLANs"
        template_name: "Dynamic_VLANs"
        template_content: "{{ lookup('template', 'templates/vlan_template.j2') }}"
```

4. **Run**

```bash
ansible-playbook -i inventory.yml create_cc_template.yml
```

✅ Catalyst Center will have a new project & template built automatically.

---

## 🧠 Review & Tips

* Keep templates in a `templates/` folder.
* Store device groups and variables in `group_vars/`.
* Always test with `--check` and `--diff` first.
* Use version control (GitHub, GitLab) for your Jinja2 files.
* Combine loops and conditionals to make smart, reusable configs.
