# Lab 3 – Policy Analysis (NEW, Enhanced)

## 📘 Introduction
Policies define how traffic flows across the SD-WAN fabric. In this lab, you’ll use Ansible to analyze configured policies (control, data, and VPN membership). This helps ensure that what you think is applied actually matches reality.

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
ansible-playbook SDWAN-lab3-policy-analysis.yml
```

---

## 📊 Expected Output
- Report showing applied policies.  
- “Valid” for correct policies, error messages if problems.

---

## 🎓 Summary
You’ve confirmed policies configured in vManage match what’s applied in the fabric. Policy verification with Ansible helps avoid outages caused by misconfiguration.
