# Lab 2 – Fabric Health (NEW, Enhanced)

## 📘 Introduction
In this lab, you will run **fabric health checks** to ensure the SD-WAN overlay is functioning correctly. You’ll use Ansible to ask vManage about control connections, data plane reachability, and site connectivity. This gives you a “doctor’s report” of the network.

---

## Step 1 – Variables
Use the same `vars.yml` file created in Lab 1.

---

## Step 2 – Playbook
This playbook queries vManage for fabric health.

```yaml
---
- name: SDWAN Lab2 — Fabric Health Check
  hosts: localhost
  gather_facts: no
  collections:
    - cisco.catalystwan

  vars_files:
    - vars.yml

  tasks:
    - name: Run health checks
      cisco.catalystwan.health_checks:
        manager_authentication:
          url: "{{ vmanage_url }}"
          username: "{{ vmanage_username }}"
          password: "{{ vmanage_password }}"
          verify: false
      register: health

    - name: Show health results
      debug:
        var: health
```

🔎 **Explanation:**  
- `health_checks` queries control and data plane health.  
- You’ll see site connectivity info, BFD/OMP session status, and alarms.  

---

## Step 3 – Run the Lab
```bash
ansible-playbook SDWAN-lab2-fabric-health.yml
```

---

## 📊 Expected Output
- Fabric summary showing `"status": "healthy"` if all is good.  
- Warnings if tunnels or sessions are down.

---

## 🎓 Summary
You used Ansible to collect a health report of the SD-WAN fabric. You now know how to quickly assess the network’s control and data plane health without logging into the GUI.
