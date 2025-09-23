

---

# Lab – IOS-XE Playbook with Variables & Inclusions

## Introduction

In this lab, you will learn how to use **variables** and **inclusions** in Ansible to make your playbooks more **reusable, modular, and easier to maintain**. Instead of writing all configuration details directly inside a single playbook, you will:

* Put variables (like hostnames, IPs, and banners) into a separate file
* Put tasks (the configuration logic) into another file
* Reference both from a small, clean main playbook

This separation is important in real-world environments because:

* **Variables** let you adjust configs per device, group, or environment without editing your playbook.
* **Inclusions** let you reuse the same task logic across multiple playbooks (e.g., “configure loopback” or “set banners”).

---

## Objectives

* Define IOS-XE variables in an external file
* Use `vars_files` to load variable definitions
* Split configuration into a separate task file
* Use `include_tasks` to keep the main playbook clean and modular
* Validate that IOS-XE devices are configured with the variables

---

## Lab Steps

### Step 1 – Create a Variables File

Create `vars_iosxe.yml`:

```yaml
hostname: CSR-DEMO
loopback_ip: 10.10.10.1
banner_message: "Welcome to CSR Demo Router - Managed by Ansible"
```

**Explanation:**
This file stores device-specific values. Instead of hardcoding them, you can just change the variables here and re-run the playbook.

---

### Step 2 – Create a Task File

Create `tasks_iosxe.yml`:

```yaml
---
- name: Set hostname
  cisco.ios.ios_config:
    lines:
      - hostname {{ hostname }}

- name: Configure Loopback0
  cisco.ios.ios_config:
    lines:
      - interface Loopback0
      - ip address {{ loopback_ip }} 255.255.255.0
      - description Configured using variables

- name: Configure MOTD banner
  cisco.ios.ios_config:
    lines:
      - banner motd ^C
      - {{ banner_message }}
      - ^C
```

**Explanation:**
These tasks use Jinja2 templating (`{{ variable }}`) to substitute values from `vars_iosxe.yml`. This means the same logic works everywhere — only the variable values change.

---

### Step 3 – Create the Main Playbook

Create `iosxe_vars_inclusions_lab.yml`:

```yaml
---
- name: IOS-XE Variables and Inclusions Lab
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars_files:
    - vars_iosxe.yml
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Include IOS-XE tasks
      include_tasks: tasks_iosxe.yml
```

**Explanation:**
The main playbook is now very short and easy to read: it loads variables, includes the tasks, and runs them. This is how you keep automation clean and maintainable.

---

### Step 4 – Run the Playbook

Run:

```bash
ansible-playbook iosxe_vars_inclusions_lab.yml -i inventory.txt
```

Observe that Ansible loads the variables, executes the included tasks, and applies the configs.

---

### Step 5 – Validate on the Device

Log into a CSR router and check:

```bash
show run | include hostname
show run interface Loopback0
show run | include banner
```

You should see the hostname, loopback, and banner as defined in `vars_iosxe.yml`.

---

## Stretch Task – Override Variables

1. Create a group variable file for `csr`:

```bash
mkdir -p group_vars/csr
nano group_vars/csr/main.yml
```

2. Add new values:

```yaml
hostname: CSR-GROUP
loopback_ip: 10.20.20.1
banner_message: "Group Vars Override - CSR Router"
```

3. Re-run your playbook. The group vars will **override** those in `vars_iosxe.yml`.

**Explanation:**
This demonstrates Ansible’s **variable precedence**: group vars > vars\_files. In production, this is how you handle different environments (lab, test, prod).

---

## Deliverables

By the end of this lab you should have:

* A variables file (`vars_iosxe.yml`)
* A task file (`tasks_iosxe.yml`)
* A clean, modular playbook (`iosxe_vars_inclusions_lab.yml`)
* IOS-XE routers configured with hostname, loopback, and banner from variables
* An understanding of variable overrides with `group_vars`

