

# Lab – IOS-XE Playbook with Ansible Vault

## Introduction

Storing credentials directly in playbooks or inventory files is insecure. If someone gains access to those files, they immediately see usernames and passwords in clear text. **Ansible Vault** solves this by encrypting sensitive data (like device credentials) while still allowing Ansible to use it during playbook execution.

In this lab, you will use Ansible Vault to protect IOS-XE device credentials. You will create an encrypted vault file, reference it in a playbook, and confirm the playbook runs securely without exposing clear text passwords.

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

Enter a password when prompted (for this lab, use `cisco`).

Inside the file, add:

```yaml
ansible_user: cisco
ansible_password: cisco
```

Save and exit.

**Explanation:**

* The file is encrypted with AES256.
* Even though credentials are inside, nobody can read them without the vault password.
* Using the same vault password (`cisco`) across your lab keeps it simple, but in production you would use a stronger secret.

---

### Step 2 – Verify Encryption

Check that the vault file is encrypted:

```bash
cat vault.yml
```

You should see scrambled text starting with `$ANSIBLE_VAULT;1.1;AES256`.

**Explanation:**
This proves that your sensitive information is no longer in plain text. Only Ansible with the correct password can decrypt it at runtime.

---

### Step 3 – Edit Vault File (Optional)

If you need to make changes:

```bash
ansible-vault edit vault.yml
```

**Explanation:**
This automatically decrypts the file in a temporary session, lets you edit, and re-encrypts it when you save.

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
      ios_config:
        lines:
          - banner motd ^C
          - This device is managed securely with Ansible Vault
          - ^C
```

**Explanation:**

* `vars_files:` points to the encrypted `vault.yml`.
* At runtime, Ansible will prompt for the vault password, decrypt the file in memory, and use the credentials.
* The credentials never appear in logs or the playbook itself.

---

### Step 5 – Run the Playbook

Run with:

```bash
ansible-playbook iosxe_vault_lab.yml --ask-vault-pass
```

When prompted, enter the vault password (`cisco`).

**Explanation:**

* `--ask-vault-pass` tells Ansible to decrypt `vault.yml` at runtime.
* The playbook executes just like normal, but credentials are loaded securely.

---

### Step 6 – Validate Configuration

On the router:

```bash
show run | include banner
```

You should see the banner configured by Ansible.

**Explanation:**
This confirms that credentials stored in the encrypted vault worked, even though they were never exposed.

---

## Stretch Task – Vault Rekey (Password Rotation)

Rotate the vault password without retyping the file contents:

```bash
ansible-vault rekey vault.yml
```

You’ll be prompted for the **old password** (`cisco`), then a **new password**.

**Explanation:**
Rekeying is like rotating your secrets. In production, teams might change vault passwords regularly to reduce risk.

---

## Deliverables

By the end of this lab you should have:

* A secure `vault.yml` with encrypted credentials
* A playbook that runs successfully using `--ask-vault-pass`
* A MOTD banner applied to IOS-XE devices
* Experience verifying that no credentials are stored or displayed in clear text
* An understanding of password rotation via `ansible-vault rekey`

---
