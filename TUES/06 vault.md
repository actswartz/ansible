

# Lab – IOS-XE Playbook with Ansible Vault

## Introduction

Storing credentials directly in playbooks or inventory files is insecure. If someone gains access to those files, they immediately see usernames and passwords in clear text. **Ansible Vault** solves this problem by encrypting sensitive data (like device credentials) while still allowing Ansible to use it during playbook execution.

In this lab, you will:

* Create a vault file containing IOS-XE device credentials
* Encrypt the file using Ansible Vault
* Reference that vault file in a playbook
* Run the playbook securely, without exposing clear text credentials

---

## Objectives

* Create and encrypt a vault file
* Store IOS-XE credentials securely
* Reference the vault file in a playbook
* Run a playbook with `--ask-vault-pass`
* Validate that credentials are never shown in plain text

---

## Lab Steps

### Step 1 – Create a Vault File

Run the following command to create and encrypt a new vault file:

```bash
ansible-vault create vault.yml
```

When prompted, enter a password (for this lab, use **`cisco`**).

Inside the file, add:

```yaml
ansible_user: cisco
ansible_password: cisco
ansible_become: yes
ansible_become_method: enable
ansible_become_password: cisco
```

**Explanation:**

* The vault file is encrypted with AES256.
* Credentials are unreadable without the vault password.
* Adding `ansible_become` ensures Ansible can enter *enable mode* for configuration commands.

---

### Step 2 – Verify Encryption

Check that the vault file is encrypted:

```bash
cat vault.yml
```

You should see scrambled text beginning with:

```
$ANSIBLE_VAULT;1.1;AES256
```

**Explanation:**
This proves your credentials are no longer in clear text. Only Ansible with the correct vault password can decrypt them.

---

### Step 3 – Edit Vault File (Optional)

If you need to update the file later:

```bash
ansible-vault edit vault.yml
```

**Explanation:**
This decrypts the file temporarily, lets you edit it, and then re-encrypts it automatically when you save.

---

### Step 4 – Create the Playbook

Create a file named `iosxe_vault_lab.yml`:

```yaml
---
- name: IOS-XE Vault Lab Playbook
  hosts: csr
  gather_facts: no
  connection: network_cli
  vars_files:
    - vault.yml

  tasks:
    - name: Configure MOTD banner
      cisco.ios.ios_config:
        lines:
          - banner motd ^C
          - This device is managed securely with Ansible Vault
          - ^C

    - name: Verify banner
      cisco.ios.ios_command:
        commands:
          - show run | include banner
      register: banner_output

    - name: Display banner verification
      debug:
        msg: |
          === BANNER CONFIGURATION ===
          {{ banner_output.stdout[0] }}
```

**Explanation:**

* `vars_files:` tells Ansible to load credentials from the encrypted `vault.yml`.
* At runtime, Ansible decrypts the file in memory. Credentials never appear in clear text.
* The playbook both **configures** (banner) and **verifies** (show command).

---

### Step 5 – Run the Playbook

Run with:

```bash
ansible-playbook iosxe_vault_lab.yml --ask-vault-pass
```

Enter the vault password (`cisco`) when prompted.

**Explanation:**

* `--ask-vault-pass` tells Ansible to decrypt `vault.yml` at runtime.
* You’ll see configuration tasks run successfully without exposing credentials.

---

### Step 6 – Validate on the Device

SSH into the router and run:

```bash
show run | include banner
```

You should see the banner configured by Ansible.

**Explanation:**
This confirms the encrypted credentials worked and Ansible successfully applied the config.

---

## Stretch Task – Vault Rekey (Password Rotation)

Change the vault password without retyping its contents:

```bash
ansible-vault rekey vault.yml
```

You’ll be prompted for the **old password** (`cisco`) and then a **new password**.

**Explanation:**
Rekeying = rotating secrets. In production, teams regularly rotate vault passwords to reduce security risk.

---

## Deliverables

By the end of this lab you should have:

* A secure `vault.yml` with encrypted credentials
* A playbook that runs successfully using `--ask-vault-pass`
* A MOTD banner applied to IOS-XE devices
* Verified the banner through Ansible output and directly on the device
* Experience with password rotation (`ansible-vault rekey`)

