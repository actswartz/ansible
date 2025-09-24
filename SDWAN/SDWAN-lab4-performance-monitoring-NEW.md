# Lab 4 – Performance Monitoring (NEW, Enhanced)

## 📘 Introduction
Performance monitoring provides visibility into how the fabric is performing in real time. In this lab, you’ll collect CPU, memory, and tunnel statistics from devices using Ansible. This helps identify performance bottlenecks early.

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
ansible-playbook SDWAN-lab4-performance-monitoring.yml
```

---

## 📊 Expected Output
- CPU and memory usage numbers.  
- Tunnel loss/latency/jitter metrics.  

---

## 🎓 Summary
You collected and displayed performance data from the SD-WAN fabric. With Ansible, this can be automated for proactive monitoring and early detection of performance issues.
