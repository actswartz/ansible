# Lab 7 – Variables & Inclusions (IOS-XE)

## Introduction

In this lab you will learn how to use variables to create interface descriptions, set MTU values, and ensure ports are enabled on a Cisco IOS-XE device.

Refer to the **Ansible-Pod-Info.docx** file for information on connecting to your Ansible host.

> **Reminder:** Change the `XX` in your inventory file based on your Pod information.

```bash
cd ~/ansible_labs/lab7-variables-inclusions
```

---

## 1. Managing Variables

### 1.1 Understanding Variables

Ansible variables can be used to store values and reuse them throughout playbooks, group\_vars, and host\_vars. This makes configuration easier to maintain.

In this lab, variables will define interface descriptions and MTU values.

Variable scopes:

1. **Global Scope** – Set from CLI or ansible.cfg
2. **Play Scope** – Defined inside playbooks
3. **Host Scope** – Defined in inventory or gathered as facts

We will focus on **group\_vars** for this lab.

---

### 1.2 Setting Up Group Vars

1. Make the folder structure:

   ```bash
   mkdir -p group_vars/ios
   ```
2. Create an **inventory** file with your IOS device in group `ios`.
3. Create an **ansible.cfg** file pointing to the inventory and disabling host key checking.
4. Create a **group\_vars/ios/ios.yaml** file.
5. Add the following variables:

```yaml
ansible_connection: network_cli
ansible_network_os: ios
ansible_user: "{{ router_user }}"
ansible_password: "{{ router_pw }}"

int_desc: "Core uplink Jumbo MTU"
int_mtu: 9216
interface: GigabitEthernet1
```

6. Use Ansible Vault to store the values of `router_user` and `router_pw`.

---

### 1.3 Creating a Playbook

Create a playbook named **int\_mtu\_example.yaml**:

```yaml
- name: Variable Example
  hosts: ios
  gather_facts: no
  tasks:
    - name: Change Interface Desc and MTU
      cisco.ios.ios_interface:
        name: "{{ interface }}"
        description: "{{ int_desc }}"
        mtu: "{{ int_mtu }}"
        enabled: true
```

Run the playbook:

```bash
ansible-playbook int_mtu_example.yaml --ask-vault-pass
```

---

### 1.4 Refactoring with Debug and Assertions

Enhance the playbook with validation:

```yaml
- name: Variable Example with Validation
  hosts: ios
  gather_facts: yes
  tasks:
    - name: Change Interface Desc and MTU
      cisco.ios.ios_interface:
        name: "{{ interface }}"
        description: "{{ int_desc }}"
        mtu: "{{ int_mtu }}"
        enabled: true

    - name: Debug MTU Value
      debug:
        var: ansible_net_interfaces[interface].mtu

    - name: Verify MTU
      assert:
        that:
          - ansible_net_interfaces[interface].mtu == int_mtu

    - name: Debug Description
      debug:
        var: ansible_net_interfaces[interface].description

    - name: Verify Description
      assert:
        that:
          - ansible_net_interfaces[interface].description == int_desc
```

---

## 2. Managing Inclusions

### 2.1 Setup

Create an **inclusions** folder and copy configs:

```bash
mkdir inclusions && cd inclusions
cp -R ../group_vars .
cp ../ansible.cfg .
cp ../inventory .
```

---

### 2.2 Creating Task and Variable Files

1. **Tasks file**

   ```bash
   mkdir tasks && cd tasks
   ```

   Create **change\_vlan.yml**:

```yaml
- name: Adding Vlan "{{ vlan_number }}"
  cisco.ios.ios_vlan:
    vlan_id: "{{ vlan_number }}"
```

2. **Variables file**

   ```bash
   cd ..
   mkdir vars && cd vars
   ```

   Create **variables.yml**:

```yaml
vlan_number: 120
```

---

### 2.3 Main Playbook

Create **playbook.yml** in project root:

```yaml
- name: Setup Vlan
  hosts: ios
  gather_facts: no
  tasks:
    - name: Include the variables from the YAML file
      include_vars: vars/variables.yml

    - name: Include the change_vlan file and set the variables
      include: tasks/change_vlan.yml
```

Check syntax:

```bash
ansible-playbook --syntax-check playbook.yml --ask-vault-pass
```

Run:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

---

### 2.4 Verify on IOS Device

SSH into the router and check:

```bash
show vlan brief
```

You should see VLAN 120 in the output.

---

## Version Control Commit

After testing, add and push your files to GitHub. Do not commit vault files.

```bash
git add lab7-variables-inclusions/
git commit -m "Add Lab 7 Variables and Inclusions for IOS-XE"
git push origin main
```
