
---

# Lab – Introduction to IOS-XE Playbooks

## Introduction

Playbooks are the heart of Ansible. They allow you to define repeatable automation tasks in a structured YAML format. Instead of running ad-hoc commands, playbooks let you:

* Target groups of devices
* Define multiple tasks in sequence
* Apply configuration and verification in one workflow

In this lab, you will create and run your first IOS-XE playbook that sets a hostname, configures a Loopback interface, applies a login banner, and verifies connectivity.

---

## Objectives

* Understand the basic structure of a playbook
* Run configuration tasks with `cisco.ios.ios_config`
* Run verification commands with `cisco.ios.ios_command`
* See how playbooks differ from ad-hoc commands

---

## Lab Steps

### Step 1 – Verify Inventory

Check that your inventory includes a group called `csr` with your IOS-XE devices.

---

### Step 2 – Create a Playbook

Create a file named `playbook_lab.yml`:

```yaml
---
- name: IOS-XE Playbook Lab
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    # Task 1: Set hostname
    - name: Configure hostname
      cisco.ios.ios_config:
        lines:
          - hostname {{ inventory_hostname }}

    # Task 2: Configure Loopback0
    - name: Configure Loopback0 interface
      cisco.ios.ios_config:
        lines:
          - interface Loopback0
          - ip address 192.168.{{ inventory_hostname[-1] }}.1 255.255.255.0
          - description Configured by Playbook Lab
        match: line

    # Task 3: Configure Login Banner
    - name: Configure login banner
      cisco.ios.ios_config:
        lines:
          - banner login ^C
          - Authorized Access Only - Managed by Ansible
          - ^C

    # Task 4: Verify device reachability
    - name: Run ping test
      cisco.ios.ios_command:
        commands:
          - ping 8.8.8.8
      register: ping_results

    # Task 5: Display ping results
    - name: Show ping results
      debug:
        msg: |
          === PING RESULTS ===
          {{ ping_results.stdout[0] }}
```

---

### Step 3 – Run the Playbook

Execute the playbook:

```bash
ansible-playbook -i inventory.txt playbook_lab.yml
```

---

### Step 4 – Validate on the Router

Log into a CSR router and check:

```bash
show run | include hostname
show run interface Loopback0
show run | include banner
ping 8.8.8.8
```

---

## Stretch Task – Add Another Task

Extend your playbook to configure an NTP server:

```yaml
    - name: Configure NTP server
      cisco.ios.ios_config:
        lines:
          - ntp server 192.168.56.200
```

Run the playbook again, then verify with:

```bash
show run | include ntp
```

---

## Deliverables

By the end of this lab you should have:

* Created your first IOS-XE playbook
* Configured hostname, loopback, and banner using Ansible
* Verified connectivity with a ping test
* Extended the playbook with an NTP configuration (stretch task)

---
