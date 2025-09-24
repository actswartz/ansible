# Lab – IOS-XE Playbooks with Loops

## Introduction

In Ansible, **loops** allow you to repeat tasks across a set of items instead of writing the same YAML multiple times. This is powerful when configuring IOS-XE devices that often require repetitive tasks: adding interfaces, NTP servers, or ACLs.

In this lab, we will explore loops in **three levels of complexity**:

1. **Simple loops with lists** (one value per iteration)
2. **Dictionary loops** (multiple parameters per item)
3. **Structured loops for complex configurations** (ACLs)
4. **Bonus – loop\_control** (making loops easier to debug and understand)

By the end, you will see how loops can reduce duplication, improve readability, and make your playbooks far more scalable.

---

## Objectives

* Learn what loops are and why they matter
* Configure multiple NTP servers using a simple loop
* Configure multiple interfaces with dictionaries
* Build ACLs with loops
* Use `loop_control` to improve debugging output

---

## Lab Steps

### Step 1 – Simple Loop Example (Lists)

Here we configure three NTP servers using a loop. Without loops, this would take three separate tasks.

```yaml
    - name: Configure multiple NTP servers with a loop
      cisco.ios.ios_config:
        lines:
          - ntp server {{ item }}
      loop:
        - 192.168.56.100
        - 192.168.56.101
        - 192.168.56.102
```

**Educational Note:**

* The `loop` keyword repeats the task for each item in the list.
* Each run substitutes `{{ item }}` with the current value.
* This is the most basic form of a loop, perfect for single-line repeated tasks like NTP servers.

Validate with:

```bash
show run | include ntp
```

---

### Step 2 – Dictionary Loop (Multiple Parameters)

Interfaces need multiple attributes (name, IP, mask, description). A simple list isn’t enough. Dictionaries let us store multiple values per item.

```yaml
    - name: Configure multiple Loopback interfaces using a loop
      cisco.ios.ios_config:
        lines:
          - ip address {{ item.ip }} {{ item.mask }}
          - description {{ item.desc }}
        parents: "interface {{ item.name }}"
      loop:
        - { name: Loopback10, ip: 10.10.10.1, mask: 255.255.255.0, desc: "Configured by Ansible - Loopback10" }
        - { name: Loopback20, ip: 10.20.20.1, mask: 255.255.255.0, desc: "Configured by Ansible - Loopback20" }
        - { name: Loopback30, ip: 10.30.30.1, mask: 255.255.255.0, desc: "Configured by Ansible - Loopback30" }
```

**Educational Note:**

* Each loop item is a **dictionary** with keys (`name`, `ip`, `mask`, `desc`).
* Dictionaries allow you to scale configurations without repeating logic.
* Adding a new interface is as simple as adding another dictionary entry.

Validate with:

```bash
show ip interface brief | include Loopback
```

---

### Step 3 – Advanced Loop (Structured Configurations)

ACLs are a great example of repetitive, structured configs. Using dictionaries, we can loop over multiple ACL entries.

```yaml
    - name: Configure ACL entries using loop
      cisco.ios.ios_config:
        lines:
          - permit {{ item.protocol }} {{ item.source }} {{ item.destination }}
        parents: "ip access-list standard LAB-ACL"
      loop:
        - { protocol: ip, source: 10.10.10.0 0.0.0.255, destination: any }
        - { protocol: ip, source: 10.20.20.0 0.0.0.255, destination: any }
```

**Educational Note:**

* ACL entries are often numerous and repetitive.
* A loop lets you define them as data, not as duplicate YAML tasks.
* This reduces errors and makes ACL changes easy to maintain.

Validate with:

```bash
show access-lists LAB-ACL
```

---

### Step 4 – Bonus: Using `loop_control`

Sometimes, loops generate a lot of output, and it’s hard to tell which item Ansible is currently working on. The `loop_control` keyword gives you more visibility.

Example:

```yaml
    - name: Configure multiple NTP servers with loop_control
      cisco.ios.ios_config:
        lines:
          - ntp server {{ item }}
      loop:
        - 192.168.56.100
        - 192.168.56.101
        - 192.168.56.102
      loop_control:
        label: "{{ item }}"
```

**Educational Note:**

* `loop_control` with `label` lets you control how each iteration is displayed in the Ansible output.
* Instead of showing the entire dictionary or internal details, you can make it show just the IP or hostname.
* This makes debugging and teaching much clearer, especially with large loops.

---

## Deliverables

By the end of this lab, you should be able to:

* Explain the benefits of loops in Ansible
* Use **list loops** for simple repetitive tasks
* Use **dictionary loops** for multi-parameter configs
* Apply loops to real-world IOS-XE scenarios like ACLs
* Use `loop_control` to make loops easier to debug and understand

---
