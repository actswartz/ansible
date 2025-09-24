# Lab – IOS-XE Playbooks with Conditionals (Progression Pack)

## Introduction

In Ansible, conditionals let you run a task **only if certain conditions are met**. Without them, playbooks apply tasks to every host, regardless of context. That can lead to wasted effort (running unnecessary checks) or even broken configs (applying settings where they don’t belong).

**Conditionals make playbooks context-aware.**
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

## Lab 1 – Very Simple Conditional

### Goal

Run a task only when a boolean condition is `true`.

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

**Information:**
This first task shows the most basic use of a conditional. The `when` keyword is attached to the task, and the task only executes if the expression evaluates to `true`. If the condition is not met, the task is skipped instead of failed, making playbooks safer and more flexible.

---

## Lab 2 – Inventory/Group Based Conditional

### Goal

Only configure hostname if the device belongs to the `csr` group.

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
      cisco.ios.ios_config:
        lines:
          - hostname {{ inventory_hostname }}
      when: "'csr' in group_names"
```

**Information:**
The variable `group_names` tracks which groups a host belongs to in your inventory file. This allows you to write a single playbook that can target multiple device types but still ensure certain commands are only executed against specific platforms. This prevents misconfigurations across different devices.

---

## Lab 3 – Registered Variable Conditional (with `ios_banner`)

### Goal

Ping an IP, then only configure a banner if the ping succeeds.

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
      cisco.ios.ios_command:
        commands:
          - ping 8.8.8.8
      register: ping_test

    - name: Configure banner only if ping succeeds
      cisco.ios.ios_banner:
        banner: motd
        text: |
          Internet connectivity confirmed - Managed by Ansible
        state: present
      when: "'!!!!' in ping_test.stdout[0]"
```

**Information:**
The first task uses the `ios_command` module to run a ping, saving the output in a registered variable. The second task uses the dedicated `ios_banner` module to configure the MOTD banner, which is more structured and safer than pushing banner text with `ios_config`. The condition ensures the banner is only created if the ping succeeds.

---

## Lab 4 – Multiple Conditions (with `ios_interface`)

### Goal

Only configure a Loopback interface if:

1. The device is a CSR, **and**
2. The ping was successful.

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
      cisco.ios.ios_interface:
        name: Loopback10
        description: Loopback created with conditionals
        enabled: true
      when:
        - "'csr' in inventory_hostname"
        - "'!!!!' in ping_test.stdout[0]"
```

**Information:**
Here, multiple conditions are checked before the task runs. The `ios_interface` module is used instead of raw configuration commands, which makes interface creation easier to read and maintain. The playbook will only create the loopback if both conditions are met, ensuring context-sensitive automation.

---

## Stretch Task – Negation

### Goal

Print a warning only if the ping **failed**.

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

**Information:**
This uses a negation check. Instead of running when the ping succeeds, this task executes only if the success markers are missing. Negation allows you to add safety mechanisms, such as alerts or fallback actions, when normal conditions are not met.

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
