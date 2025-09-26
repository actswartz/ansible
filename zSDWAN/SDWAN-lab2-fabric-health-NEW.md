# Lab 2 – Fabric Health (NEW, Enhanced)

## 📘 Introduction
In this lab, you will run **fabric health checks** to ensure the SD-WAN overlay is functioning correctly. You’ll use Ansible to ask vManage about control connections, data plane reachability, and site connectivity. This gives you a “doctor’s report” of the network.

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
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab2-fabric-health.yml
```

---

## 📊 Expected Output
- Fabric summary showing `"status": "healthy"` if all is good.  
- Warnings if tunnels or sessions are down.

---

## 🎓 Summary
You used Ansible to collect a health report of the SD-WAN fabric. You now know how to quickly assess the network’s control and data plane health without logging into the GUI.
