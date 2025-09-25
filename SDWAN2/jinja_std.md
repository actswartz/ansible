
---

# 🧪 Lab Book — Jinja2 Templates for Ansible

---

## Lab 0 — Goal & Setup

**Goal:**
Learn how to use Jinja2 templates to make your Ansible playbooks **dynamic** and **reusable**.

**You Will Learn To:**

* Use variables in templates
* Loop and conditionally render content
* Create interface and VLAN configs dynamically
* Build templates for real network use

**Setup:**

* Python 3.8+, Ansible Core 2.13+
* A Linux control node
* Cisco sandbox (Catalyst, IOS-XE) or local dev environment
* Inventory file ready

```bash
sudo apt install ansible
```

---

## Lab 1 — First Template: A Simple Banner

1. **Create template file** `banner.j2`

```jinja
!
banner motd ^
Welcome to {{ inventory_hostname }}
Authorized users only!
^
```

2. **Playbook to deploy**

```yaml
---
- name: Deploy Banner
  hosts: switches
  gather_facts: no
  tasks:
    - name: Push banner using template
      ios_config:
        src: banner.j2
```

3. **Run:**

```bash
ansible-playbook deploy_banner.yml
```

✅ Observe how the hostname is injected dynamically.

---

## Lab 2 — Loops: Generate Interfaces

1. `interfaces.j2`

```jinja
{% for intf in interfaces %}
interface {{ intf.name }}
 description {{ intf.desc }}
 switchport access vlan {{ intf.vlan }}
 spanning-tree portfast
{% endfor %}
```

2. Vars in `group_vars/all.yml`

```yaml
interfaces:
  - { name: Gig1/0/1, desc: User1, vlan: 10 }
  - { name: Gig1/0/2, desc: User2, vlan: 20 }
```

3. Playbook:

```yaml
---
- name: Configure Interfaces
  hosts: switches
  gather_facts: no
  tasks:
    - name: Push interface config
      ios_config:
        src: interfaces.j2
```

---

## Lab 3 — Conditionals: Add Optional Config

1. `interface_conditional.j2`

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

2. Vars:

```yaml
interfaces:
  - { name: Gig1/0/3, desc: HR-PC, vlan: 30, portfast: true }
  - { name: Gig1/0/4, desc: Camera, vlan: 40 }
```

3. Playbook (same as Lab 2 but using new template)

✅ Notice portfast line appears only when `portfast: true`.

---

## Lab 4 — Dynamic VLAN List

1. `vlans.j2`

```jinja
{% for vlan in vlans %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% endfor %}
```

2. Vars:

```yaml
vlans:
  - { id: 10, name: USERS }
  - { id: 20, name: VOICE }
  - { id: 30, name: CAMERAS }
```

3. Playbook:

```yaml
---
- name: Create VLANs
  hosts: switches
  gather_facts: no
  tasks:
    - ios_config:
        src: vlans.j2
```

---

## Lab 5 — Combining Templates with Catalyst Center

Use Jinja2 to feed dynamic configs into Catalyst Center templates.

1. `vlan_template.j2`

```jinja
{% for vlan in vlans %}
interface vlan {{ vlan.id }}
 ip address {{ vlan.ip }} 255.255.255.0
 no shut
{% endfor %}
```

2. Playbook:

```yaml
---
- name: Create VLAN Template in Catalyst Center
  hosts: localhost
  collections:
    - cisco.dnac
  vars:
    dnac_host: "{{ dnac_host }}"
    dnac_username: "{{ dnac_username }}"
    dnac_password: "{{ dnac_password }}"
  tasks:
    - dnac_template_create:
        dnac_host: "{{ dnac_host }}"
        dnac_username: "{{ dnac_username }}"
        dnac_password: "{{ dnac_password }}"
        project_name: "Campus_VLANs"
        template_name: "Dynamic_VLANs"
        template_content: "{{ lookup('template', 'vlan_template.j2') }}"
```

✅ Builds a Catalyst Center template dynamically using your variable list.

---

## Extra Practice

* Add **default values** in templates:
  `{{ variable | default('fallback') }}`
* Use **loops inside conditionals**.
* Create one master playbook to deploy banners, VLANs, and interfaces.

---

Would you like me to export this **lab book** as a nicely formatted **PDF** or **Markdown file** so you can hand it out to students directly?
