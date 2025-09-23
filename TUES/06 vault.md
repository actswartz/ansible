# Lab 6 – Vault (IOS-XE)

## Introduction

Ansible Vault allows us to keep sensitive and secret data like passwords, API keys, etc., in encrypted files rather than storing them in plaintext playbooks or elsewhere where someone could see them.

In this lab we will explore Vault and its use cases, focusing on **Cisco IOS-XE devices**.

Refer to the **Ansible-Pod-Info.docx** file for information on connecting to your Ansible host.

> **Reminder:** Change the `XX` in your inventory file based on your Pod information.

```bash
cd ~/ansible_labs/lab6-vault
```

---

## 1. Encrypting Existing Files

We’ll start by creating a file with login information for an IOS-XE router, then encrypt it with Vault.

```bash
echo 'router_user: admin' >> ssh_pass.txt
echo 'router_pw: password' >> ssh_pass.txt
```

Check the file:

```bash
cat ssh_pass.txt
```

Encrypt it:

```bash
ansible-vault encrypt ssh_pass.txt
```

Enter `ansible` (or another password you’ll remember).

---

## 2. Viewing Encrypted Files

Use `ansible-vault view` to look inside:

```bash
ansible-vault view ssh_pass.txt
```

It will prompt for the vault password and then show:

```yaml
router_user: admin
router_pw: password
```

---

## 3. Creating/Editing Encrypted Files

Instead of creating a plaintext file and encrypting later, we can directly create vault files.

```bash
ansible-vault create group_vars/ios/vault
```

Enter `ansible` as the vault password. Add the following lines:

```yaml
router_user: username_here
router_pw: password_here
```

Save with `:wq!`.

To edit later:

```bash
ansible-vault edit group_vars/ios/vault
```

---

## 4. Using the Vault in Playbooks

Here’s an example group\_vars file:

```yaml
# group_vars/ios/vars.yml
ansible_connection: network_cli
ansible_network_os: ios
ansible_user: "{{ router_user }}"
ansible_password: "{{ router_pw }}"
```

Now test with a simple facts playbook:

```bash
ansible-playbook -i inventory ios_facts_play.yaml --ask-vault-pass
```

---

## 5. Decrypting Files

To permanently decrypt:

```bash
ansible-vault decrypt ssh_pass.txt
```

---

## 6. Rekey (Change Vault Password)

Re-encrypt if needed, then run:

```bash
ansible-vault rekey ssh_pass.txt
```

---

## 7. Vault Password File

Instead of typing the password every time:

```bash
echo 'ansible' > .vault_pass
ansible-playbook -i inventory ios_facts_play.yaml --vault-password-file=.vault_pass
```

---

## 8. Environment Variable

Set an environment variable:

```bash
export ANSIBLE_VAULT_PASSWORD_FILE=./.vault_pass
ansible-playbook -i inventory ios_facts_play.yaml
```

---

## 9. Knowledge Check 1

**Use Case:** Store SSH username/password in Vault for IOS-XE router and configure a playbook to set the MOTD.

1. Working directory: `section9_knowledgecheck`
2. Create vault with router login info.
3. Create playbook to set an MOTD on the IOS device.
4. Group is `ios` in the inventory file.
5. MOTD can be any text.
6. Use group\_vars + vault so that running is as simple as:

```bash
ansible-playbook ios ios_motd.yaml
```

Helpful Links:

* [Ansible IOS Guide](https://docs.ansible.com/ansible/latest/network/user_guide/platform_ios.html)
* [ios\_banner module](https://docs.ansible.com/ansible/latest/collections/cisco/ios/ios_banner_module.html)

---

## 10. Securing Sensitive Data (MOTD in Vault)

Move MOTD text into Vault:

```bash
ansible-vault edit group_vars/ios/vault
```

Add:

```yaml
router_user: admin
router_pw: password
motd_message: This is my secure MOTD message, stored in Vault.
```

Copy your playbook:

```bash
cp ios_motd.yaml secure_change_motd.yaml
```

Edit it:

```yaml
- name: Configure MOTD securely
  hosts: ios
  tasks:
    - name: Configure banner MOTD
      cisco.ios.ios_banner:
        banner: motd
        text: "{{ motd_message }}"
```

Run:

```bash
ansible-playbook -i inventory secure_change_motd.yaml
```

---

## 11. Knowledge Check 2

**Use Case:** Secure a playbook with sensitive data so it can be version-controlled.

1. Working directory: `section11_knowledgecheck`
2. Copy over your section9 setup (`cp -r ../section9_knowledgecheck .`).
3. Ensure all sensitive info (user/pass/MOTD) is in Vault.
4. Verify playbook runs successfully.
5. Push to GitHub repo, but **don’t add Vault file to version control**.
