Here's the corrected Markdown file with proper code blocks:

**Lab Guide: Ansible for Cisco IOS XE - VLAN and SVI Configuration**

**1. Project Overview**

Welcome! In this lab, you will use Ansible to automate network configurations on 10 Cisco CSR1000V routers. You will perform two main tasks:

1.  Create a specific VLAN across all 10 routers.

2.  Create a Switched Virtual Interface (SVI) for that VLAN on each router, assigning a unique IP address to each one.

This project will teach you how to set up your Ansible environment, write and execute playbooks, use variables, and apply configurations idempotently. We will also explore two different methods for configuring interfaces: a static definition and a more dynamic loop-based approach.

**2. Prerequisites**

-   Access to the lab environment with 10 CSR1000V routers.

-   Ansible installed on your control node (the machine you are working from).

-   Network connectivity from your control node to the management interfaces of all 10 routers.

-   Your assigned student number (1 through 10). Your VLAN ID will be 200 + your student number. For example, Student 1 uses VLAN 201, Student 8 uses VLAN 208, etc.

**3. Lab Procedure**

Follow these steps to set up your environment and execute the automation. Create a dedicated folder for this project and place all the files you create inside it.

**Step 1: Set Up Your Environment & Core Files**

First, we need to create the core files that tell Ansible how to behave and which devices to manage.

🧠 Challenge Yourself!

Before you copy the files below, take a moment to search on Google. How would you find the information needed for these first two files? Try searching for terms like:

-   "ansible configuration file for cisco ios"

-   "ansible inventory file example"

-   "ansible host variables"

See if the examples you find match what's provided in the lab. This is a great way to learn how to find solutions independently!

1.  **Create the Ansible Configuration File (ansible.cfg)**. This file defines the inventory file location, connection settings, and default credentials.

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

2. **Create the Ansible Inventory File (inventory.ini)**. This is the list of all the devices you want to manage. We also define a custom variable router_id for each device, which we will use later to generate unique IP addresses.

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

3. **Crucially, edit ansible.cfg** and update the ansible_user and ansible_password with the correct credentials for the lab routers.

    -   **What's Happening?** You are creating the foundational files for your Ansible project and providing Ansible with the username and password it needs to log into the Cisco routers. Without this, the connection will fail.

**Step 2: Create and Deploy the VLAN**

Now, let's write and run our first playbook to create the VLAN.

🧠 Challenge Yourself!

Before creating the playbook, think about how you would solve this problem. Head over to Google and try searching for:

-   "ansible create vlan cisco ios"

-   "ansible module for cisco vlans"

-   "cisco.ios.ios_vlans ansible example"

Review the official Ansible documentation or community examples. Can you piece together what the playbook should look like before revealing the solution below?

1.  **Create the VLAN Playbook (create_vlan.yml)**. This playbook's job is to ensure your assigned VLAN exists on all routers.

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

2. **Edit the vlan_id variable** at the top of the file to your assigned VLAN ID (e.g., 201 for Student 1).

3. **Execute the playbook** from your terminal:

```bash
ansible-playbook create_vlan.yml
```

    -   **What's Happening?** When you run this command, Ansible reads your playbook and inventory file. It then connects to each of the 10 routers in sequence. For each router, it checks if your specified VLAN already exists. Since this is the first run, the VLAN does not exist, so Ansible will send the necessary commands (vlan 201, name Student_201_VLAN) to create it.

4. **Verification:** The output will show changed for each router. If you run it a second time, it should show ok because the VLAN already exists (this demonstrates idempotency). You can also log in to a router and run `show vlan brief` to see your new VLAN.

    -   **What's Happening?** The changed status confirms that Ansible modified the router's configuration. If you run the playbook again, Ansible will check the router, see that VLAN 201 is already configured correctly, and do nothing, resulting in an ok status. This "state-checking" is a core principle of Ansible.

**Step 3: Configure the SVI (Two Methods)**

Next, we will configure the SVI for your VLAN. We will explore two different ways to write the playbook to achieve the same result. While both are effective, the ultimate goal of this lab is for you to understand and use the more advanced **Dynamic Loop Approach (Method 2)**, as it represents a more powerful and scalable pattern for real-world automation.

🧠 Challenge Yourself!

Now for the final task. Before looking at the two methods below, can you figure out how to configure a Layer 3 interface with an IP address? Try searching Google for:

-   "ansible configure cisco interface ip address"

-   "ansible svi configuration example"

-   "cisco.ios.ios_l3_interfaces module"

This is the most complex task in the lab. Spending a few minutes researching will significantly help you understand the solutions provided.

**Method 1: The Static Approach**

This is the most straightforward method, where we define the interface configuration directly in the playbook task.

1.  **Create the Static SVI Playbook (configure_svi_static.yml)**.

```yaml
---
- name: Configure SVI on Cisco Routers (Static Method)
  hosts: cisco_routers
  gather_facts: no
  connection: network_cli

  vars:
    # ------------------------------------------------------------------
    # STUDENT: Update this vlan_id with your assigned number (201-210)
    # ------------------------------------------------------------------
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

2. **Edit the vlan_id variable** to match the one you used previously.

3. **Execute the playbook:**

```bash
ansible-playbook configure_svi_static.yml
```

    -   **What's Happening?** Ansible connects to all 10 routers and uses the cisco.ios.ios_l3_interfaces module. It dynamically builds the IP address for each router by combining the vlan_id (e.g., 201) with each router's unique router_id from the inventory file. For the router at 10.1.64.205, it generates the address 10.10.201.5/24 and applies it to the interface Vlan201.

4. **Verification:** Log in to a few routers to check the interface configuration. For example, on 10.1.64.203 (assuming VLAN 201), you should see interface Vlan201 with IP 10.10.201.3. Use the command: `show ip interface brief | include Vlan`.

**Method 2: The Dynamic Loop Approach (Advanced)**

This method accomplishes the same goal but uses a more programmatic technique to first build the configuration in a variable, and then apply it. This pattern is powerful for more complex automation.

1.  **Create the Loop SVI Playbook (configure_svi_loop.yml)**.

```yaml
---
- name: Configure SVI on Cisco Routers (Loop Method)
  hosts: cisco_routers
  gather_facts: no
  connection: network_cli

  vars:
    # ------------------------------------------------------------------
    # STUDENT: Update this vlan_id with your assigned number (201-210)
    # ------------------------------------------------------------------
    vlan_id: 201

  tasks:
    - name: Build list of interface configurations
      set_fact:
        l3_interfaces_config: "{{ l3_interfaces_config|default([]) + [{'name': 'Vlan' + vlan_id|string, 'ipv4': [{'address': '10.10.' + vlan_id|string + '.' + router_id|string + '/24'}]}] }}"

    - name: Configure VLAN Interfaces using loop-built config
      cisco.ios.ios_l3_interfaces:
        config: "{{ l3_interfaces_config }}"
        state: merged
      register: svi_output

    - name: Print SVI configuration output
      debug:
        var: svi_output
```

2. **Edit the vlan_id variable**.

3. **Execute the playbook:**

```bash
ansible-playbook configure_svi_loop.yml
```

    -   **What's Happening?** The first task, set_fact, doesn't configure the router; it builds a complex variable (l3_interfaces_config) in memory. The second task then uses this dynamically built variable to configure the interface.

4. **Verification:** The result on the routers will be identical. Because the configuration is already correct from the last step, the output should show ok for all routers, not changed.

    -   **What's Happening with Verification?** This step perfectly demonstrates idempotency. Ansible connects to each router and sees that interface Vlan\<your_vlan\> already exists with the correct IP address. Since the router's *current state* matches the playbook's *desired state*, Ansible makes no changes and reports an ok status.

**4. Super Challenge (Optional)**

You've learned the basics. Now it's time to solve a problem on your own. For this challenge, you will create a new playbook from scratch without a provided solution. Your goal is to research the correct Ansible modules and parameters to accomplish the tasks below.

**Challenge A: Configure a Switchport**

-   **Goal:** On your individual router ONLY (e.g., Student 1 on 10.1.64.201, Student 5 on 10.1.64.205), configure the GigabitEthernet2 interface to be a Layer 2 access port assigned to your VLAN.

-   **Hints:**

    -   How do you make a playbook run against only one device? Consider the `--limit` flag on the command line or a `when` condition in your playbook.

    -   Search for the Ansible module designed to configure Layer 2 interfaces on IOS: `cisco.ios.ios_l2_interfaces`. The documentation for this module has examples that will be very helpful.

**Challenge B: Enable OSPF**

-   **Goal:** Enable OSPF on the new SVI you created across **all 10 routers**. Use OSPF process ID 1 and assign the interface to area 0.

-   **Hints:**

    -   Look for an Ansible module specifically for configuring OSPF on interfaces. A good search term would be "ansible cisco ios ospf interface".

    -   The module you are looking for is likely `cisco.ios.ios_ospf_interfaces`.

    -   How will you tell the module to configure the correct Vlan\<your_id\> interface?

**5. Lab Conclusion**

Congratulations! You have successfully used Ansible to automate the configuration of VLANs and SVIs on multiple Cisco routers. You have learned to:

-   Set up an Ansible project with configuration and inventory files.

-   Write and execute playbooks for Cisco IOS devices.

-   Use variables to make playbooks reusable and dynamic.

-   Implement two different design patterns (static vs. loop-based) to achieve the same configuration outcome.

-   Verify automation changes on network devices.
