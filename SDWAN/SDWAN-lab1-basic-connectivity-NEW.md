# Lab 1 – Basic Connectivity Check (NEW, Enhanced)

## 📘 Introduction
In this first lab, you’ll begin working with **Ansible and Cisco Catalyst SD-WAN (vManage)**. Before diving into advanced automation, it’s essential to prove that Ansible can successfully talk to vManage. This lab focuses on establishing that baseline connectivity by logging in, checking vManage’s status, and retrieving a list of devices.

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

## Step 1 – Set Up Variables
You’ll create a file called `vars.yml` to hold your vManage URL, username, and password. Keeping credentials separate from the playbook is best practice and makes your playbook reusable.

```yaml
vmanage_url: "https://<vmanage-ip-or-host>"
vmanage_username: "admin"
vmanage_password: "your_password"
```

---

## Step 2 – Create the Playbook
This playbook checks vManage’s health and lists vEdge devices.

```yaml
---
- name: SDWAN Lab1 — Basic Connectivity Check
  hosts: localhost
  gather_facts: no
  collections:
    - cisco.catalystwan

  vars_files:
    - vars.yml

  tasks:
    - name: Get Manager Info
      cisco.catalystwan.manager_info:
        manager_authentication:
          url: "{{ vmanage_url }}"
          username: "{{ vmanage_username }}"
          password: "{{ vmanage_password }}"
          verify: false
      register: mgr

    - name: Show Manager Info
      debug:
        var: mgr

    - name: Get Devices
      cisco.catalystwan.devices_info:
        manager_authentication:
          url: "{{ vmanage_url }}"
          username: "{{ vmanage_username }}"
          password: "{{ vmanage_password }}"
          verify: false
        device_category: vedges
      register: devices

    - name: Show Devices
      debug:
        var: devices
```

🔎 **Explanation:**  
- `manager_info` checks if vManage is alive.  
- `devices_info` pulls device inventory.  
- `debug` prints raw data to help you see what’s happening.

---

## Step 3 – Run the Lab
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab1-basic-connectivity.yml
```

---

## 📊 Expected Output
- **Manager Info:** Status should be “active” with version and uptime.  
- **Devices:** vEdges listed with system IPs and reachability.  
- If no devices, check your setup.

---

## 🎓 Summary
You validated connectivity between Ansible and vManage. This proves the foundation works: your automation environment can query SD-WAN Manager APIs. Later labs will build on this to analyze health, policies, and compliance.
