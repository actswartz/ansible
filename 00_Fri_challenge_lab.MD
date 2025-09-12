Got it ✅ — I’ll wrap the commands, YAML, and configuration examples in proper fenced code blocks so your Markdown renders correctly.

Here’s the fixed version:

---

# **Lab Guide: Ansible for Cisco IOS XE - VLAN and SVI Configuration**

## **1. Project Overview**

Welcome! In this lab, you will use Ansible to automate network configurations on 10 Cisco CSR1000V routers. You will perform two main tasks:

1. Create a specific VLAN across all 10 routers.  
2. Create a Switched Virtual Interface (SVI) for that VLAN on each router, assigning a unique IP address to each one.

This project will teach you how to set up your Ansible environment, write and execute playbooks, use variables, and apply configurations idempotently. We will also explore two different methods for configuring interfaces: a static definition and a more dynamic loop-based approach.

---

## **2. Prerequisites**

- Access to the lab environment with 10 CSR1000V routers.  
- Ansible installed on your control node (the machine you are working from).  
- Network connectivity from your control node to the management interfaces of all 10 routers.  
- Your assigned student number (1 through 10). Your VLAN ID will be `200 + your student number`.  
  Example: Student 1 uses VLAN 201, Student 8 uses VLAN 208, etc.

---

## **3. Lab Procedure**

Follow these steps to set up your environment and execute the automation.  
Create a dedicated folder for this project and place all the files you create inside it.

---

### **Step 1: Set Up Your Environment & Core Files**

First, we need to create the core files that tell Ansible how to behave and which devices to manage.

🧠 **Challenge Yourself!**  
Before you copy the files below, try searching Google for:

- `"ansible configuration file for cisco ios"`
- `"ansible inventory file example"`
- `"ansible host variables"`

---

#### **Create the Ansible Configuration File (`ansible.cfg`)**
```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
timeout = 30
ansible_connection = network_cli
ansible_network_os = cisco.ios.ios
ansible_user = your_username
ansible_password = your_password

[persistent_connection]
connect_timeout = 60
command_timeout = 60
```

---

#### **Create the Ansible Inventory File (`inventory.ini`)**
```ini
[cisco_routers]
10.1.64.201 router_id=1
10.1.64.202 router_id=2
10.1.64.203 router_id=3
10.1.64.204 router_id=4
10.1.64.205 router_id=5
10.1.64.206 router_id=6
10.1.64.207 router_id=7
10.1.64.208 router_id=8
10.1.64.209 router_id=9
10.1.64.210 router_id=10
```

✏️ Update `ansible_user` and `ansible_password` in `ansible.cfg` with the correct credentials.

---

### **Step 2: Create and Deploy the VLAN**

---

#### **Create the VLAN Playbook (`create_vlan.yml`)**
```yaml
---
- name: Create VLAN on Cisco Routers
  hosts: cisco_routers
  gather_facts: no
  connection: network_cli

  vars:
    # ------------------------------------------------------------------
    # STUDENT: Update this vlan_id with your assigned number (201-210)
    # ------------------------------------------------------------------
    vlan_id: 201

  tasks:
    - name: "Ensure VLAN {{ vlan_id }} exists"
      cisco.ios.ios_vlans:
        config:
          - vlan_id: "{{ vlan_id }}"
            name: "Student_{{ vlan_id }}_VLAN"
        state: merged
      register: vlan_output

    - name: Print VLAN creation output
      debug:
        var: vlan_output
```

---

#### **Run the playbook:**
```bash
ansible-playbook create_vlan.yml
```

---

### **Step 3: Configure the SVI (Two Methods)**

---

#### **Method 1: Static Approach (`configure_svi_static.yml`)**
```yaml
---
- name: Configure SVI on Cisco Routers (Static Method)
  hosts: cisco_routers
  gather_facts: no
  connection: network_cli

  vars:
    vlan_id: 201

  tasks:
    - name: Configure VLAN Interface with Static IP
      cisco.ios.ios_l3_interfaces:
        config:
          - name: "Vlan{{ vlan_id }}"
            ipv4:
              - address: "10.10.{{ vlan_id }}.{{ router_id }}/24"
        state: merged
      register: svi_output

    - name: Print SVI configuration output
      debug:
        var: svi_output
```

Run:
```bash
ansible-playbook configure_svi_static.yml
```

---

#### **Method 2: Dynamic Loop Approach (`configure_svi_loop.yml`)**
```yaml
---
- name: Configure SVI on Cisco Routers (Loop Method)
  hosts: cisco_routers
  gather_facts: no
  connection: network_cli

  vars:
    vlan_id: 201

  tasks:
    - name: Build list of interface configurations
      set_fact:
        l3_interfaces_config: "{{ l3_interfaces_config | default([]) + [{'name': 'Vlan' + vlan_id|string, 'ipv4': [{'address': '10.10.' + vlan_id|string + '.' + router_id|string + '/24'}]}] }}"

    - name: Configure VLAN Interfaces using loop-built config
      cisco.ios.ios_l3_interfaces:
        config: "{{ l3_interfaces_config }}"
        state: merged
      register: svi_output

    - name: Print SVI configuration output
      debug:
        var: svi_output
```

Run:
```bash
ansible-playbook configure_svi_loop.yml
```

---

## **4. Super Challenge (Optional)**

---

### **Challenge A: Configure a Switchport**
```yaml
---
- name: Configure access port on individual router
  hosts: 10.1.64.201
  gather_facts: no
  connection: network_cli

  vars:
    vlan_id: 201

  tasks:
    - name: Configure GigabitEthernet2 as access port
      cisco.ios.ios_l2_interfaces:
        config:
          - name: GigabitEthernet2
            mode: access
            access:
              vlan: "{{ vlan_id }}"
        state: merged
```

---

### **Challenge B: Enable OSPF**
```yaml
---
- name: Enable OSPF on VLAN SVI
  hosts: cisco_routers
  gather_facts: no
  connection: network_cli

  vars:
    vlan_id: 201

  tasks:
    - name: Configure OSPF on VLAN interface
      cisco.ios.ios_ospf_interfaces:
        config:
          - name: "Vlan{{ vlan_id }}"
            address_family:
              - afi: ipv4
                processes:
                  - id: 1
                    area:
                      area_id: 0
        state: merged
```

---

Do you want me to also **add syntax highlighting** for Ansible YAML and `ini` files so it’s easier to read in your Markdown viewer? That would make the guide even more polished.
