# Lab – IOS-XE Playbooks with Jinja2 Templating 

## Introduction

Jinja2 is the **templating engine** built into Ansible. It allows you to stop writing rigid, one-off configurations and instead design **blueprints** that adapt automatically to different devices.

With Jinja2 you can:

* Use **variables** to insert dynamic values (e.g., hostnames, IPs).
* Use **loops** to repeat sections of configuration automatically.
* Use **conditionals** to generate config only when rules are met.

This transforms your playbooks from static scripts into **scalable, intelligent automation frameworks**.

---

## Lab 1 – Simple Variable Substitution

**Goal:**
Learn how to use Jinja2 variables to make configurations reusable. Instead of hardcoding hostnames or banner text, you will define them in a separate variables file and substitute them into a template. This is the foundation of templating: separating **data** (variables) from **logic** (templates).

**vars file (`vars_lab1.yml`):**

```yaml
hostname: CSR-TEMPLATE
banner_message: "Welcome to CSR Router - Managed by Ansible Jinja2"
```

**template file (`lab1_template.j2`):**

```jinja
hostname {{ hostname }}

banner motd ^C
{{ banner_message }}
^C
```

**Information:**
The placeholders `{{ hostname }}` and `{{ banner_message }}` are dynamically replaced by Ansible with the values stored in your variables file. This approach makes templates reusable across multiple devices. You can adjust the hostname or banner by editing just the variables, without ever touching the template itself.

---

## Lab 2 – Loops in Jinja2

**Goal:**
Learn how to generate repeated configurations dynamically. Instead of copy-pasting interface configs, you’ll use a loop to automatically build loopback interfaces based on a list of variables. This demonstrates how Jinja2 handles **scalable, repetitive tasks** efficiently.

**vars file (`vars_lab2.yml`):**

```yaml
loopbacks:
  - { id: 10, ip: 10.10.10.1, mask: 255.255.255.0 }
  - { id: 20, ip: 10.20.20.1, mask: 255.255.255.0 }
```

**template file (`lab2_template.j2`):**

```jinja
{% for lb in loopbacks %}
interface Loopback{{ lb.id }}
 ip address {{ lb.ip }} {{ lb.mask }}
 description Configured by Jinja2 loop
{% endfor %}
```

**Information:**
The `{% for %}` loop cycles through each dictionary in the list of loopbacks. Each loop iteration generates a unique configuration block for that loopback. If you need more interfaces, you only add new data in the variables file — the template logic stays the same.

---

## Lab 3 – Conditionals in Jinja2

**Goal:**
Learn how to control whether or not certain parts of the configuration are generated. This teaches how Jinja2 conditionals (`{% if %}`) give templates the ability to **make decisions** based on rules.

**vars file (`vars_lab3.yml`):**

```yaml
loopbacks:
  - { id: 10, ip: 10.10.10.1, mask: 255.255.255.0 }
  - { id: 20, ip: 10.20.20.1, mask: 255.255.255.0 }
```

**template file (`lab3_template.j2`):**

```jinja
{% for lb in loopbacks %}
{% if lb.id > 15 %}
interface Loopback{{ lb.id }}
 ip address {{ lb.ip }} {{ lb.mask }}
 description Configured only when ID > 15
{% endif %}
{% endfor %}
```

**Information:**
This template uses a conditional inside a loop. Configurations are created only when the condition is satisfied (`id > 15`). This logic makes templates smarter and helps build context-aware configs, such as enabling IPv6 only when required or applying role-based settings depending on the router’s function.

---

## Lab 4 – Combining Variables, Loops, and Conditionals

**Goal:**
Learn how to build a **complete, dynamic device config** by combining all Jinja2 concepts. This lab simulates a real-world scenario where some features (like NTP) are optional and others (like loopbacks, hostnames, and banners) are always present.

**vars file (`vars_lab4.yml`):**

```yaml
hostname: CSR-COMPLEX
banner_message: "Dynamic Config with Jinja2"
ntp_enabled: true
loopbacks:
  - { id: 30, ip: 10.30.30.1, mask: 255.255.255.0 }
  - { id: 40, ip: 10.40.40.1, mask: 255.255.255.0 }
```

**template file (`lab4_template.j2`):**

```jinja
hostname {{ hostname }}

banner motd ^C
{{ banner_message }}
^C

{% if ntp_enabled %}
ntp server 192.168.56.200
{% endif %}

{% for lb in loopbacks %}
interface Loopback{{ lb.id }}
 ip address {{ lb.ip }} {{ lb.mask }}
 description Configured by advanced Jinja2 template
{% endfor %}
```

**Information:**
This combined template shows how different Jinja2 constructs work together. Variables define unique values like the hostname, loops generate repeated structures like loopbacks, and conditionals ensure optional features like NTP are only included when flagged. With this design, one template can serve many roles just by changing the data file.

---

## Lab 5 – Apply with Playbook

**Goal:**
Learn how to **render a Jinja2 template into a configuration file** and then safely push it to the router. This models a real production workflow where configs are reviewed before deployment.

**playbook (`jinja2_lab.yml`):**

```yaml
---
- name: IOS-XE Jinja2 Template Progression Lab
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars_files:
    - vars_lab4.yml
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Render config from Jinja2 template
      template:
        src: lab4_template.j2
        dest: rendered_config.txt

    - name: Apply rendered config to device
      cisco.ios.ios_config:
        src: rendered_config.txt
```

**Information:**
This playbook follows a two-step workflow. First, the `template` module generates a rendered text file based on variables and the template. Second, the `ios_config` module applies that generated configuration to the device. This workflow mimics real-world operations, where engineers want to review configs before pushing them live.

---

## Stretch Task – Nested Loops

**Goal:**
Learn how to model hierarchical data (like VLANs with associated interfaces). This helps you understand how Jinja2 scales to large, complex configs.

**template file (`nested_template.j2`):**

```jinja
{% for vlan in vlans %}
vlan {{ vlan.id }}
 name {{ vlan.name }}
{% for intf in vlan.interfaces %}
interface {{ intf }}
 switchport access vlan {{ vlan.id }}
{% endfor %}
{% endfor %}
```

**Information:**
The outer loop builds VLAN definitions, and the inner loop assigns interfaces to those VLANs. This mirrors real production use cases like ACL entries, BGP neighbors, or VRFs. Nested loops are powerful for modeling hierarchical relationships in network configurations.

---

## Deliverables

By completing this progression, you will:

* Understand and use **variables, loops, and conditionals** in Jinja2.
* Write templates that scale across many routers.
* Safely render and apply configs.
* Build reusable templates for real-world scenarios.

---

✨ **Key Takeaway:**
Jinja2 shifts automation from writing **static configs** to writing **rules that generate configs**. With one smart template and multiple variable files, you can automate entire networks at scale.
