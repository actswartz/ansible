# Lab 5 – Security Compliance (NEW, Enhanced)

## 📘 Introduction
Security compliance ensures devices meet defined baselines and policies. In this final lab, you’ll run Ansible to check device compliance against security standards. This validates whether your SD-WAN environment is secure and properly configured.

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
This playbook runs security compliance checks.

```yaml
---
- name: SDWAN Lab5 — Security Compliance
  hosts: localhost
  gather_facts: no
  collections:
    - cisco.catalystwan

  vars_files:
    - vars.yml

  tasks:
    - name: Run security compliance checks
      cisco.catalystwan.security_compliance:
        manager_authentication:
          url: "{{ vmanage_url }}"
          username: "{{ vmanage_username }}"
          password: "{{ vmanage_password }}"
          verify: false
      register: compliance

    - name: Show compliance results
      debug:
        var: compliance
```

🔎 **Explanation:**  
- `security_compliance` checks devices against defined baselines.  
- Reports which devices pass or fail.

---

## Step 3 – Run the Lab
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab5-security-compliance.yml
```

---

## 📊 Expected Output
- Compliance results with pass/fail per device.  
- ✅ “Compliant” devices meet the baseline.  
- ❌ “Non-compliant” devices require remediation.

---

## 🎓 Summary
You validated the security posture of your SD-WAN devices. Ansible can now be used to automate compliance checks, ensuring your network consistently meets organizational and regulatory standards.
