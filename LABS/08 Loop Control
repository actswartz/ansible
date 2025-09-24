# Lab – IOS-XE Playbooks with `loop_control`

## Introduction

When you run a loop in Ansible, the output shows every iteration. By default, Ansible prints the **entire data structure** for each item in the loop (which can be long and messy if you’re looping over dictionaries).

This makes it hard to read and debug, especially if you’re looping through:

* Dozens of interfaces with multiple parameters
* Complex ACL entries
* Device lists with long dictionaries

The **`loop_control`** keyword gives you control over how Ansible **labels and displays each iteration** in the output. This is especially useful in training environments (to help learners see what’s happening) and in production (to quickly spot errors).

---

## Objectives

* Learn the purpose of `loop_control`
* Use `loop_control` with `label` to customize task output
* Understand how `loop_control` improves readability and debugging
* Compare output with and without `loop_control`

---

## Lab Steps

### Step 1 – Default Loop Behavior

Create `loopcontrol_lab.yml` with this task:

```yaml
---
- name: Loop Control Lab - Default Behavior
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars:
    ansible_become: yes
    ansible_become_method: enable
    ansible_become_password: cisco

  tasks:
    - name: Configure interfaces (default loop output)
      cisco.ios.ios_config:
        lines:
          - ip address {{ item.ip }} {{ item.mask }}
          - description {{ item.desc }}
        parents: "interface {{ item.name }}"
      loop:
        - { name: Loopback80, ip: 10.80.80.1, mask: 255.255.255.0, desc: "Configured with default loop" }
        - { name: Loopback90, ip: 10.90.90.1, mask: 255.255.255.0, desc: "Configured with default loop" }
```

**Educational Note:**

* Without `loop_control`, Ansible will print the **entire dictionary** (`{ name: Loopback80, ip: 10.80.80.1, ... }`) in the output for each iteration.
* This is technically fine, but gets cluttered with large data sets.

---

### Step 2 – Using `loop_control` with `label`

Now add another task in the same playbook using `loop_control`:

```yaml
    - name: Configure interfaces (clean output with loop_control)
      cisco.ios.ios_config:
        lines:
          - ip address {{ item.ip }} {{ item.mask }}
          - description {{ item.desc }}
        parents: "interface {{ item.name }}"
      loop:
        - { name: Loopback100, ip: 10.100.100.1, mask: 255.255.255.0, desc: "Configured with loop_control" }
        - { name: Loopback110, ip: 10.110.110.1, mask: 255.255.255.0, desc: "Configured with loop_control" }
      loop_control:
        label: "{{ item.name }}"
```

**Educational Note:**

* `loop_control: label` changes how Ansible displays each iteration.
* Instead of showing the whole dictionary, the output will only show the **label you pick** (here, the interface name).
* This makes the playbook output easier to scan: you can immediately tell which interface is being configured.

---

### Step 3 – Run the Playbook

Execute:

```bash
ansible-playbook -i inventory.txt loopcontrol_lab.yml
```

Compare outputs:

* **Task 1 (default loop):** long dictionaries in the output.
* **Task 2 (with loop\_control):** clean output showing only `Loopback100` and `Loopback110`.

---

### Step 4 – Validate on the Router

Check the new interfaces:

```bash
show ip interface brief | include Loopback
```

You should see Loopback80, Loopback90, Loopback100, and Loopback110 configured.

---

## Deliverables

By the end of this lab, you should be able to:

* Recognize default loop output in Ansible
* Use `loop_control` to label iterations with a meaningful identifier
* Explain why `loop_control` makes debugging easier in large loops
* Confirm IOS-XE interfaces configured correctly

---

✨ **Key takeaway:** `loop_control` doesn’t change what Ansible *does*, but it changes what Ansible *shows*. This small improvement in readability can save hours of frustration in large-scale automation.

---

