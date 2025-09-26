# Lab 3 – Policy Analysis (NEW, Enhanced)

## 📘 Introduction
Policies define how traffic flows across the SD-WAN fabric. In this lab, you’ll use Ansible to analyze configured policies (control, data, and VPN membership). This helps ensure that what you think is applied actually matches reality.

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
This playbook runs a policy analysis job.

```yaml
---
- name: SDWAN Lab3 — Policy Analysis
  hosts: localhost
  gather_facts: no
  collections:
    - cisco.catalystwan

  vars_files:
    - vars.yml

  tasks:
    - name: Run policy analysis
      cisco.catalystwan.policy_analysis:
        manager_authentication:
          url: "{{ vmanage_url }}"
          username: "{{ vmanage_username }}"
          password: "{{ vmanage_password }}"
          verify: false
      register: policy

    - name: Show policy results
      debug:
        var: policy
```

🔎 **Explanation:**  
- `policy_analysis` retrieves how policies are applied.  
- It validates syntax and highlights conflicts or errors.

---

## Step 3 – Run the Lab
```bash
ansible-playbook -i SDWAN-inventory.txt SDWAN-lab3-policy-analysis.yml
```

---

## 📊 Expected Output
- Report showing applied policies.  
- “Valid” for correct policies, error messages if problems.

---

## 🎓 Summary
You’ve confirmed policies configured in vManage match what’s applied in the fabric. Policy verification with Ansible helps avoid outages caused by misconfiguration.
