# Lab 1 – Basic Connectivity Check (NEW, Enhanced)

## 📘 Introduction
In this first lab, you’ll begin working with **Ansible and Cisco Catalyst SD-WAN (vManage)**. Before diving into advanced automation, it’s essential to prove that Ansible can successfully talk to vManage. This lab focuses on establishing that baseline connectivity by logging in, checking vManage’s status, and retrieving a list of devices.

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
ansible-playbook SDWAN-lab1-basic-connectivity.yml
```

---

## 📊 Expected Output
- **Manager Info:** Status should be “active” with version and uptime.  
- **Devices:** vEdges listed with system IPs and reachability.  
- If no devices, check your setup.

---

## 🎓 Summary
You validated connectivity between Ansible and vManage. This proves the foundation works: your automation environment can query SD-WAN Manager APIs. Later labs will build on this to analyze health, policies, and compliance.
