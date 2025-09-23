

# Lab – IOS-XE Playbook with Vault (Group `csr`)

## Introduction

In this lab, you will learn how to use **Ansible Vault** with a single inventory group called `csr`. You will securely store device credentials in an encrypted file and use them in a playbook that configures a banner on IOS-XE devices.

## Objectives

* Create a vault file for the `csr` group
* Encrypt credentials with Ansible Vault
* Reference vault automatically through `group_vars`
* Run the playbook and confirm results

## Lab Steps

### Step 1 – Create Group Vars Directory

Create a `group_vars` directory for the `csr` group:

```bash
mkdir -p group_vars/csr
```

### Step 2 – Create Vault File

Create and encrypt a vault file for the group:

```bash
ansible-vault create group_vars/csr/vault.yml
```

Inside, add:

```yaml
ansible_user: cisco
ansible_password: cisco
```

Save and exit. This file will be encrypted.

### Step 3 – Create the Playbook

Create a playbook named `iosxe_vault_group.yml`:

```yaml
---
- name: IOS-XE Group Vault Playbook
  hosts: csr
  gather_facts: no
  connection: network_cli

  tasks:
    - name: Configure MOTD banner
      ios_config:
        lines:
          - banner motd ^C
          - Welcome to CSR router - Secured with Vault
          - ^C

    - name: Verify device version
      ios_command:
        commands:
          - show version
      register: version_output

    - name: Display version info
      debug:
        var: version_output.stdout_lines
```

Note: You do **not** need `vars_files:` here — Ansible will load `group_vars/csr/vault.yml` automatically.

### Step 4 – Run the Playbook

Run the playbook, providing the vault password:

```bash
ansible-playbook iosxe_vault_group.yml --ask-vault-pass
```

### Step 5 – Validate

Log into a CSR router and check:

```bash
show run | include banner
```

You should see the MOTD banner applied.

---

## Stretch Task – Use `--vault-id` with Password File

1. Save the password `cisco` in a local file:

```bash
echo 'cisco' > .vault_pass.txt
chmod 600 .vault_pass.txt
```

2. Rekey the vault to use this file:

```bash
ansible-vault rekey group_vars/csr/vault.yml --vault-password-file .vault_pass.txt
```

3. Re-run your playbook using non-interactive vault authentication:

```bash
ansible-playbook iosxe_vault_group.yml --vault-id .vault_pass.txt
```

---

## Deliverables

By the end of this lab you should have:

* Encrypted credentials stored in `group_vars/csr/vault.yml`
* A playbook that configures a MOTD banner using Vault
* Verified device information displayed in the output
* Experience with both interactive (`--ask-vault-pass`) and automated (`--vault-id`) vault use

\
