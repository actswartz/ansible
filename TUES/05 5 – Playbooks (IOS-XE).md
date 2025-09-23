

# Lab – IOS-XE Playbook

## Introduction

In this lab, you will run an Ansible playbook against Cisco IOS-XE devices (CSR routers). The playbook configures basic settings, including hostname, Loopback interface, a MOTD banner, and verifies connectivity with a ping test. You will also complete a stretch task to configure NTP and Syslog for centralized management.

## Objectives

* Apply Ansible playbooks to IOS-XE devices
* Configure hostname and interfaces using `ios_config`
* Set a Message of the Day (MOTD) banner
* Verify connectivity using `ios_ping`
* Stretch: Configure NTP and Syslog with Ansible

## Lab Steps

### Step 1 – Verify Inventory

Check that your `inventory.txt` file has devices listed under the `csr` group:

```bash
cat inventory.txt
```

### Step 2 – Review the Playbook

Open `iosxe_lab.yml` and confirm the following tasks:

* Set the hostname
* Configure Loopback0 interface
* Configure MOTD banner
* Verify reachability to 8.8.8.8

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

## Stretch Task – NTP and Syslog Configuration

Extend the playbook by adding two new tasks:

* Configure an NTP server (e.g., `192.168.56.200`)
* Configure a Syslog server (e.g., `192.168.56.201`)

### Example Tasks

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

### Validation

On the CSR router, run:

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
