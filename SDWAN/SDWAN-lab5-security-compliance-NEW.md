# Lab 5 – Security Compliance (NEW, Enhanced)

## 📘 Introduction
Security compliance ensures devices meet defined baselines and policies. In this final lab, you’ll run Ansible to check device compliance against security standards. This validates whether your SD-WAN environment is secure and properly configured.

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
ansible-playbook SDWAN-lab5-security-compliance.yml
```

---

## 📊 Expected Output
- Compliance results with pass/fail per device.  
- ✅ “Compliant” devices meet the baseline.  
- ❌ “Non-compliant” devices require remediation.

---

## 🎓 Summary
You validated the security posture of your SD-WAN devices. Ansible can now be used to automate compliance checks, ensuring your network consistently meets organizational and regulatory standards.
