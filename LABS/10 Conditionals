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
    - name: Always skipped unless condition is true
      debug:
        msg: "This task only runs when condition is true"
      when: true
```

**Educational Note:**
This seems trivial, but it’s your first look at Ansible’s **conditional execution model**. Every task can have a `when:` clause. If the condition is false, the task is **skipped** (not failed). This introduces safety: you can define tasks that only run in specific scenarios.

---

## Lab 2 – Inventory/Group Based Conditional

### Goal

Only configure hostname if the device belongs to the `csr` group.

```yaml
    - name: Configure hostname only for CSR group
      cisco.ios.ios_config:
        lines:
          - hostname {{ inventory_hostname }}
      when: "'csr' in group_names"
```

**Educational Note:**

* `group_names` is a built-in Ansible variable that lists all groups a host belongs to.
* Using it allows you to build **multi-device-type playbooks** but still apply certain configs only where they belong.
* This is key in production, where you might have a mix of CSR routers, Catalyst switches, and Nexus devices.

---

## Lab 3 – Registered Variable Conditional

### Goal

Ping an IP, then only configure a banner if the ping succeeds.

```yaml
    - name: Ping Google DNS
      cisco.ios.ios_command:
        commands:
          - ping 8.8.8.8
      register: ping_test

    - name: Configure banner only if ping succeeds
      cisco.ios.ios_config:
        lines:
          - banner motd ^C
          - Internet connectivity confirmed - Managed by Ansible
          - ^C
      when: "'!!!!' in ping_test.stdout[0]"
```

**Educational Note:**

* `register` saves task results into a variable (`ping_test`).
* You can reference its values inside a `when` condition.
* In this case, a Cisco IOS XE successful ping prints `!!!!`. The condition checks for that string.
* This is **reactive automation** — Ansible makes decisions based on real device feedback.

---

## Lab 4 – Multiple Conditions

### Goal

Only configure a Loopback interface if:

1. The device is a CSR, **and**
2. The ping was successful.

```yaml
    - name: Configure Loopback10 if CSR and ping succeeded
      cisco.ios.ios_config:
        lines:
          - ip address 10.123.123.1 255.255.255.0
          - description Loopback created with conditionals
        parents: "interface Loopback10"
      when:
        - "'csr' in inventory_hostname"
        - "'!!!!' in ping_test.stdout[0]"
```

**Educational Note:**

* `when` can take a list of conditions.
* All must be true for the task to run.
* This is where Ansible starts to feel like a **rules engine** — tasks only apply when the environment matches your logic.

---

## Stretch Task – Negation

### Goal

Print a warning only if the ping **failed**.

```yaml
    - name: Print warning if ping failed
      debug:
        msg: "Ping to 8.8.8.8 failed!"
      when: "'!!!!' not in ping_test.stdout[0]"
```

**Educational Note:**
Negation is just as important as positive conditions. Sometimes you only want a task to fire in *failure* scenarios (e.g., run a backup config if the primary check fails).

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
Conditionals let you build **adaptive playbooks**. Instead of blindly running the same set of tasks, your automation **responds to context** — the type of device, test results, or the outcome of previous steps.

---

