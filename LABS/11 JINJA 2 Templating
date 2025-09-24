# Lab – IOS-XE Playbooks with Jinja2 Templating (Progression Pack)

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

**Explanation:**

* `{{ hostname }}` and `{{ banner_message }}` are placeholders.
* Jinja2 replaces them with values from `vars_lab1.yml` at runtime.
* One template now works for many routers — you only need to update the variable file.

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

**Explanation:**

* `{% for lb in loopbacks %}` loops through each dictionary in the list.
* Each iteration generates an interface block with its own ID, IP, and mask.
* Adding new interfaces = just add a new entry in the vars file.

This is where automation shines: you define *data once* and let Jinja2 generate all the configs.

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

**Explanation:**

* The template only generates configs for loopbacks with ID > 15.
* This introduces **logic-based configuration**.
* Real-world use cases:

  * Only configure BGP if router role == edge.
  * Only enable IPv6 if a flag is true.
  * Only apply special banners in production.

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

**Explanation:**

* `hostname` and `banner` are filled in from variables.
* `ntp_enabled` flag controls whether NTP config is added.
* Loop generates all loopbacks.

This template is **device-role aware** — changing a single variable file can make it behave differently for HQ, branch, or lab routers.

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

  tasks:
    - name: Render config from Jinja2 template
      template:
        src: lab4_template.j2
        dest: rendered_config.txt

    - name: Apply rendered config to device
      cisco.ios.ios_config:
        src: rendered_config.txt
```

**Explanation:**

* First task: `template` generates a plain-text config (`rendered_config.txt`).
* Second task: pushes that config to the router with `ios_config`.
* This workflow is standard in production: **review first, deploy second**.

---

## Stretch Task – Nested Loops

**Goal:**
Learn how to model hierarchical data (like VLANs with associated interfaces). This helps students understand how Jinja2 scales to large, complex configs.

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

**Explanation:**

* Outer loop builds VLANs.
* Inner loop assigns interfaces to those VLANs.
* This approach works for ACLs, VRFs, BGP neighbors, or any hierarchical config.

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

---

