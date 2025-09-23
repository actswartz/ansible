

# Lab – IOS-XE Playbook with Variables & Inclusions

## Introduction

In this lab, you will learn how to use **variables** and **inclusions** in Ansible to make your playbooks more **reusable, modular, and easier to maintain**. Instead of writing all configuration details directly inside a single playbook, you will separate the variables (like hostnames and IPs) into a variable file, and the tasks (like configuration commands) into a task file. Then, your main playbook will simply *include* these files.

This separation is important in real-world environments because:

* **Variables** allow you to adjust configurations per device, per group, or per environment without editing the main playbook.
* **Inclusions** allow you to reuse the same task logic across multiple playbooks (e.g., “configure interfaces” or “set banners”).

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

Explanation: This file stores all of your device-specific values. Instead of hardcoding these into the playbook, you can change them here and rerun the same playbook.

---

### Step 2 – Create a Task File

Create `tasks_iosxe.yml`:

```yaml
---
- name: Set hostname
  ios_config:
    lines:
      - hostname {{ hostname }}

- name: Configure Loopback0
  ios_config:
    lines:
      - interface Loopback0
      - ip address {{ loopback_ip }} 255.255.255.0
      - description Configured using variables

- name: Configure MOTD banner
  ios_config:
    lines:
      - banner motd ^C
      - {{ banner_message }}
      - ^C
```

Explanation: These tasks use Jinja2 templating (`{{ variable }}`) to insert values from `vars_iosxe.yml`. This means the same tasks can be reused for different hosts or groups by simply changing variable files.

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

  tasks:
    - name: Include IOS-XE tasks
      include_tasks: tasks_iosxe.yml
```

Explanation: Notice how clean the main playbook is now — it doesn’t contain the details of configs. It just points to the variables file and includes the task list.

---

### Step 4 – Run the Playbook

Run your playbook:

```bash
ansible-playbook iosxe_vars_inclusions_lab.yml
```

Observe that Ansible loads the variables, executes the included tasks, and applies the configurations to your IOS-XE routers.

---

### Step 5 – Validate on the Device

Log into a CSR router and confirm:

```bash
show run | include hostname
show run interface Loopback0
show run | include banner
```

You should see the hostname, loopback, and banner as defined in your variable file.

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

3. Re-run your playbook. The group variables will override the ones in `vars_iosxe.yml`.

Explanation: This demonstrates how **variable precedence** works in Ansible — group variables can take priority over defaults or manually included files.

---

## Deliverables

By the end of this lab you should have:

* A variables file (`vars_iosxe.yml`)
* A task file (`tasks_iosxe.yml`)
* A clean, modular playbook (`iosxe_vars_inclusions_lab.yml`)
* Configurations applied to IOS-XE routers using variables
* An understanding of variable overrides with `group_vars`

---
