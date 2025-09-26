
# Lab – IOS-XE Playbooks with Conditionals 

## Introduction

In Ansible, conditionals let you run a task **only if certain conditions are met**. Without them, playbooks apply tasks to every host, regardless of context. That can lead to wasted effort (running unnecessary checks) or even broken configs (applying settings where they don’t belong).

Conditionals make playbooks **context-aware**.
They act like *if statements* in programming:

* *If the device is a CSR, set the hostname.*
* *If the ping is successful, configure a banner.*
* *If both conditions are true, create a loopback.*

By the end of this lab sequence, you’ll see how conditionals transform playbooks from **static scripts** into **intelligent automation tools**.

---

## Objectives

* Learn the `when` statement syntax in playbooks
* Practice with simple true/false conditions
* Apply conditions based on group membership or hostnames
* Use registered variables inside conditions
* Chain multiple conditions together
* Explore negation (run a task only if something fails)

---

## Step 0 – Install the Cisco IOS Collection

On your Ansible control node, install the Cisco IOS collection. Without this, `ios_config`, `ios_banner`, and `ios_command` will not work:

```bash
ansible-galaxy collection install cisco.ios
```

---

## Lab 1 – Very Simple Conditional

### Goal

Run a task only when a boolean condition is `true`.

1. Create the file:

```bash
nano conditional_lab1.yml
```

2. Paste this playbook:

```yaml
---
- name: Simple Conditional Example
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Always skipped unless condition is true
      debug:
        msg: "This task only runs when condition is true"
      when: true
```

3. Save and exit (`CTRL+O`, `ENTER`, `CTRL+X`).

4. Run it:

```bash
ansible-playbook -i inventory.txt conditional_lab1.yml
```

**Information:**
This is the simplest form of conditional logic. The task only executes if `when: true` evaluates to true. If you flip it to `false`, the task is skipped. Notice how Ansible outputs **“skipped”** instead of failing — this is key for safe automation. You can test “what if” scenarios without breaking devices.

---

## Lab 2 – Inventory/Group Based Conditional

### Goal

Only configure hostname if the device belongs to the `csr` group.

```bash
nano conditional_lab2.yml
```

Paste:

```yaml
---
- name: Hostname Conditional Example
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Configure hostname only for CSR group
      ios_config:
        lines:
          - hostname {{ inventory_hostname }}
      when: "'csr' in group_names"
```

Run:

```bash
ansible-playbook -i inventory.txt conditional_lab2.yml
```

**Information:**
Here you’re combining **inventory logic** with conditionals. `group_names` is a built-in Ansible variable that lists all groups the current host belongs to. If your inventory has routers, switches, and firewalls, you can still use one playbook — but ensure only the right tasks apply to the right devices. This keeps automation safe in mixed environments.

---

## Lab 3 – Registered Variable Conditional (with `ios_banner`)

### Goal

Ping an IP, then only configure a banner if the ping succeeds.

```bash
nano conditional_lab3.yml
```

Paste:

```yaml
---
- name: Registered Variable Conditional Example
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Ping Google DNS
      ios_command:
        commands:
          - ping 8.8.8.8
      register: ping_test

    - name: Configure banner only if ping succeeds
      ios_banner:
        banner: motd
        text: |
          Internet connectivity confirmed - Managed by Ansible
        state: present
      when: "'!!!!' in ping_test.stdout[0]"
```

Run:

```bash
ansible-playbook -i inventory.txt conditional_lab3.yml
```

**Information:**
The first task executes a CLI command and **registers** its output into a variable (`ping_test`). The second task uses `when:` to inspect that variable. Cisco IOS marks successful pings with `!!!!`. By checking for this, you make the playbook *reactive*. This is real-world automation: tasks run only if the environment confirms it’s safe.

---

## Lab 4 – Multiple Conditions

### Goal

Only configure a Loopback interface if:

1. The device is a CSR, **and**
2. The ping was successful.

```bash
nano conditional_lab4.yml
```

Paste:

```yaml
---
- name: Multiple Conditions Example
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Configure Loopback10 if CSR and ping succeeded
      ios_config:
        lines:
          - interface Loopback10
          - ip address 10.123.123.1 255.255.255.0
          - description Loopback created with conditionals
      when:
        - "'csr' in inventory_hostname"
        - "'!!!!' in ping_test.stdout[0]"
```

Run:

```bash
ansible-playbook -i inventory.txt conditional_lab4.yml
```

**Information:**
Here you chain conditions together. Both must be true before the loopback is created. This is especially powerful in production: you can check device type, feature support, test results, or version numbers before applying configurations. It prevents misconfigurations and enforces **policy-driven automation**.

---

## Stretch Task – Negation

### Goal

Print a warning only if the ping **failed**.

```bash
nano conditional_lab5.yml
```

Paste:

```yaml
---
- name: Negation Example
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Print warning if ping failed
      debug:
        msg: "Ping to 8.8.8.8 failed!"
      when: "'!!!!' not in ping_test.stdout[0]"
```

Run:

```bash
ansible-playbook -i inventory.txt conditional_lab5.yml
```

**Information:**
This reverses the logic. Instead of running on success, it runs only on failure. Negation is important in **self-healing playbooks**. For example: if a service is down, trigger a backup or raise an alert. It gives automation the ability to handle “what if things go wrong” scenarios.

---

## Deliverables

By completing this progression, you should be able to:

* Write **simple conditionals** (`when: true/false`)
* Use **inventory-based conditions** (`group_names`, `inventory_hostname`)
* Work with **registered variables** inside conditionals
* Chain **multiple conditions** together for advanced scenarios
* Apply **negation** for failure-handling tasks

---

✨ **Key takeaway:**
Conditionals let you build **adaptive playbooks**. Instead of blindly running the same set of tasks, your automation **responds to context** — the type of device, test results, or the outcome of previous steps. This makes playbooks more reliable, efficient, and safer to run in production environments.

---

