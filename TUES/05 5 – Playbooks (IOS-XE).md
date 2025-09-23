# Lab 5 – Playbooks (IOS-XE)

## Introduction

Playbooks are like instruction manuals for your orchestration tasks. They tell Ansible what to do and in what order.

They are written in **YAML** format, which relies heavily on spacing and indentation.

Refer to the **Lab Connection Information.docx** file for details on connecting to your Ansible host.

> **Reminder:** Change the `XX` in your inventory file based on your Pod information.

```bash
cd ~/ansible_labs/lab5-playbooks
```

---

## 1. Ansible Plays and Tasks

### 1.1 Understanding Plays

A “Play” is a mapping of a set of hosts to tasks. Each **task** calls an Ansible module (such as `ios_facts`) to perform a specific action.

You can have multiple plays in a playbook to complete multiple stages of a job.

We’ll start with a basic playbook example, run it, and discuss the output.

When prompted for a password, use the **IOS-XE router password** provided on your lab sheet.

We’ll specify `-u` for username and `-k` to be prompted for the password.

---

### 1.2 Running a Playbook

First, check which hosts the playbook will run against:

```bash
ansible-playbook -i inventory ios_facts_play.yaml --list-hosts
```

Now, run the playbook:

```bash
ansible-playbook -i inventory ios_facts_play.yaml -u admin -k -e ansible_network_os=ios
```

---

### 1.3 Example Output

You should see something like:

```
playbook: ios_facts_play.yaml
  play #1 (ios): Gather IOS Facts    TAGS: []
    pattern: [u'ios']
    hosts (1):
      csr1000v-XX.localdomain
```

```
PLAY [Gather IOS Facts] **********************************************************************

TASK [Gathering Facts] ************************************************************************
ok: [csr1000v-XX.localdomain]

TASK [ios_facts] ******************************************************************************
ok: [csr1000v-XX.localdomain]

TASK [Get All Ip Addresses] *******************************************************************
ok: [csr1000v-XX.localdomain] => {
    "ansible_net_all_ipv4_addresses": [
        "10.10.20.30",
        "192.168.1.1",
        "172.16.1.1"
    ]
}

PLAY RECAP ************************************************************************************
csr1000v-XX.localdomain : ok=3    changed=0    unreachable=0    failed=0
```

---

### 1.4 Playbook Example

```yaml
---
- name: Gather IOS Facts
  hosts: ios
  connection: network_cli
  gather_facts: yes

  tasks:
    - name: Collect IOS Facts
      cisco.ios.ios_facts:

    - name: Get All IP Addresses
      debug:
        var: ansible_net_all_ipv4_addresses
```

---

## 2. Create Multi-Task Playbook

**Use Case:** Generate a report of IOS device versions and models.

### Instructions

1. Working folder: `section2_multitask`
2. Use the inventory file: `sectiontwo_inv`
3. Create a playbook called **two\_task.yaml** with 2 tasks:

   * Gather facts
   * Debug the **model** and **version**
4. Run with:

```bash
ansible-playbook -i sectiontwo_inv two_task.yaml -u admin -k -e ansible_network_os=ios
```

5. Add the playbook to your Git repo, commit, and push.

---

## 3. Host & Group Vars

Instead of putting variables in playbooks or CLI, best practice is to use **group\_vars** or **host\_vars**.

Example structure:

```
lab5-playbooks/section5_snmp/group_vars/ios
```

File contents (`group_vars/ios`):

```yaml
ansible_connection: network_cli
ansible_network_os: ios
ansible_user: admin
```

This way you don’t need to pass `-u admin` or `-e ansible_network_os=ios` every time.

---

## 4. Assert & Verifying Changes

Use the **assert** module to verify changes.

### Example Playbook: Change Description

```yaml
---
- name: Change Interface Description and Assert
  hosts: ios
  connection: network_cli
  gather_facts: yes

  tasks:
    - name: Change GigabitEthernet1 Description
      cisco.ios.ios_interface:
        name: GigabitEthernet1
        description: 'uplink to core'

    - name: Gather facts again
      cisco.ios.ios_facts:

    - name: Debug Interface Description
      debug:
        var: ansible_net_interfaces['GigabitEthernet1']['description']

    - name: Verify change was made
      assert:
        that:
          - ansible_net_interfaces['GigabitEthernet1']['description'] == 'uplink to core'
```

Run:

```bash
ansible-playbook -i inventory assert_example.yaml -u admin -k
```

Expected output:

```
TASK [Verify change was made]
ok: [csr1000v-XX.localdomain] => {
    "changed": false,
    "msg": "All assertions passed"
}
```

---

## 5. Knowledge Check – Configure SNMP Community String

**Use Case:** Configure a new SNMP community string on all IOS devices, then use assert to verify.

1. Use `cisco.ios.ios_snmp_community` module → [docs](https://docs.ansible.com/ansible/latest/collections/cisco/ios/ios_snmp_community_module.html)
2. Define variables in `group_vars/ios` (community string value).
3. Create a playbook that references these variables.
4. Run playbook and use `assert` to confirm the change.

---

## Version Control Commit

Add your new playbooks to version control:

```bash
git add lab5-playbooks/
git commit -m "Add IOS-XE Playbooks lab"
git push origin main
```

---

Would you like me to **rewrite all the example command outputs** (e.g., PLAY RECAP, TASK logs) so they consistently show **csr1000v-XX.localdomain** instead of `n9k-standalone-XX.localdomain`?
