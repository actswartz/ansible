# Lab 4 – Performance Monitoring (NEW, Enhanced)

## 📘 Introduction
Performance monitoring provides visibility into how the fabric is performing in real time. In this lab, you’ll collect CPU, memory, and tunnel statistics from devices using Ansible. This helps identify performance bottlenecks early.

---

## 📂 Inventory Setup
## 🔎 Understanding the Inventory File

The file `SDWAN-inventory.txt` is an **Ansible inventory**. Inventories tell Ansible *which hosts to run tasks on*.

In our labs, the inventory contains:
```
[local]
localhost ansible_connection=local
```

- `[local]` is a group name — here we only have one group called "local".  
- `localhost` means the playbook will run on your local control machine, not on a remote server.  
- `ansible_connection=local` tells Ansible to run modules directly on the local machine instead of trying SSH.

👉 Even though the playbooks target `localhost`, the actual API calls go from your Ansible control machine to **vManage** over HTTPS using the modules in the `cisco.catalystwan` collection.


In this lab, instead of only using `vars.yml`, you will also rely on an **Ansible inventory file** named `SDWAN-inventory.txt`.
This file is provided to you and already contains the host definition for `localhost` (your control machine).

Example (`SDWAN-inventory.txt`):
```
[local]
localhost ansible_connection=local
```
You will still use `vars.yml` for your vManage URL, username, and password, but the playbooks will now be run with the inventory file specified.

---

## Step 1 – Variables
Use the same `vars.yml` from Lab 1.

---

## Step 2 – Playbook
This playbook runs performance monitoring tasks.

```yaml
---
- name: SDWAN Lab4 — Performance Monitoring
  hosts: localhost
  gather_facts: no
  collections:
    - cisco.catalystwan

  vars_files:
    - vars.yml

  tasks:
    - name: Collect performance metrics
      cisco.catalystwan.performance_monitor:
        manager_authentication:
          url: "{{ vmanage_url }}"
          username: "{{ vmanage_username }}"
          password: "{{ vmanage_password }}"
          verify: false
      register: perf

    - name: Show performance metrics
      debug:
        var: perf
```

🔎 **Explanation:**  
- `performance_monitor` queries device stats.  
- Metrics may include CPU, memory, interface errors, and tunnel quality.

---

## Step 3 – Run the Lab
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab4-performance-monitoring.yml
```

---

## 📊 Expected Output
- CPU and memory usage numbers.  
- Tunnel loss/latency/jitter metrics.  

---

## 🎓 Summary
You collected and displayed performance data from the SD-WAN fabric. With Ansible, this can be automated for proactive monitoring and early detection of performance issues.
