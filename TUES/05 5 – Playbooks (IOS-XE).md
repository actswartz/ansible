
# Lab – IOS-XE Playbook

## Introduction

In this lab, you will create and run an Ansible playbook against Cisco IOS-XE devices (CSR routers). The playbook will configure hostnames, Loopback interfaces, a MOTD banner, and will verify connectivity with a ping test. You will also extend the playbook with a stretch task to configure NTP and Syslog.

## Objectives

* Create an Ansible playbook from scratch
* Apply configurations to IOS-XE devices
* Configure hostname, interfaces, and a MOTD banner
* Verify connectivity using `ios_ping`
* Stretch: Add NTP and Syslog configuration

## Lab Steps

### Step 1 – Verify Inventory

Check that your `inventory.txt` file has devices listed under the `csr` group:

```bash
cat inventory.txt
```

### Step 2 – Create the Playbook

Use a text editor to create a new file named `iosxe_lab.yml`:

```bash
nano iosxe_lab.yml
```

Enter the following content:

```yaml
---
- name: IOS-XE Lab Playbook
  hosts: csr
  gather_facts: no
  connection: network_cli
  become: yes

  tasks:
    - name: Ensure hostname is set
      ios_config:
        lines:
          - hostname {{ inventory_hostname }}

    - name: Configure Loopback0 interface
      ios_config:
        lines:
          - interface Loopback0
          - ip address 10.{{ inventory_hostname[-1] }}.{{ inventory_hostname[-1] }}.1 255.255.255.0
          - description Configured by Ansible
        match: line

    - name: Configure MOTD banner
      ios_config:
        lines:
          - banner motd ^C
          - Welcome to {{ inventory_hostname }} - Configured by Ansible
          - ^C

    - name: Verify reachability to gateway
      ios_ping:
        dest: 8.8.8.8
      register: ping_output

    - name: Show ping results
      debug:
        var: ping_output
```

Save and exit the file.

### Step 3 – Run the Playbook

Execute the playbook against the `csr` group:

```bash
ansible-playbook -i inventory.txt iosxe_lab.yml
```

### Step 4 – Observe the Output

Review Ansible’s output as it applies configuration and runs the ping check.
Look for changes made to the hostname, interface, and banner.

### Step 5 – Validate the Configuration

Log into a CSR router and verify:

```bash
show run | include hostname
show run interface Loopback0
show run | include banner
ping 8.8.8.8
```

## Stretch Task – NTP and Syslog

Modify your `iosxe_lab.yml` file and add these tasks under the `tasks:` section:

```yaml
    - name: Configure NTP server
      ios_config:
        lines:
          - ntp server 192.168.56.200

    - name: Configure Syslog server
      ios_config:
        lines:
          - logging host 192.168.56.201
```

Re-run the playbook:

```bash
ansible-playbook -i inventory.txt iosxe_lab.yml
```

Validate on the router:

```bash
show run | include ntp
show run | include logging host
```

## Deliverables

By the end of this lab you should have:

* Hostnames configured on each CSR router
* Loopback0 interface with assigned IP address
* A MOTD banner displayed at login
* NTP and Syslog configured (stretch task)
* Successful ping verification in Ansible output

---

