
# Educational Lab Guide: Using Ansible with Cisco DNA Center

## 1. Introduction

This lab guide provides a hands-on introduction to automating Cisco DNA Center (DNAC) operations using Ansible. You will learn how to leverage the official `cisco.dnac` Ansible Collection to interact with the DNAC API, moving from basic device discovery to more advanced operational tasks like monitoring site health.

By the end of this lab, you will be able to:
*   Set up an Ansible environment for DNAC automation.
*   Write and execute a playbook to retrieve a list of all network devices.
*   Write and execute a second playbook to check the health status of all network sites.
*   Understand the structure of the data returned by the DNAC API.

## 2. Prerequisites

Before you begin, ensure you have the following:

*   **Ansible:** Installed on your local machine (version 2.9 or later).
*   **Cisco DNAC Ansible Collection:** The `cisco.dnac` collection must be installed.
*   **DNAC Center SDK:** The `dnacentersdk` Python library must be installed.
*   **Cisco DNA Center Sandbox:** Access to a DNAC sandbox environment.
*   **Text Editor:** A text editor of your choice (e.g., VS Code, Sublime Text, Atom).

**Cisco DNA Center Credentials:**

*   **DNAC Address:** `198.18.129.100`
*   **Username:** `admin`
*   **Password:** `C1sco12345`

## 3. Lab Environment Setup

First, let's prepare the working directory and Ansible configuration files.

1.  **Create a Project Directory:**
    Open your terminal and create a new directory for this lab.
    ```bash
    mkdir ansible-dnac-lab
    cd ansible-dnac-lab
    ```

2.  **Install Dependencies:**
    Install the required Ansible collection and Python SDK.
    ```bash
    ansible-galaxy collection install cisco.dnac
    pip install dnacentersdk
    ```

3.  **Create an Ansible Inventory File:**
    Create a file named `inventory.ini`. We will target `localhost` because the `cisco.dnac` modules run on the Ansible control node and connect to the DNAC API remotely.
    ```ini
    [dnac]
    localhost
    ```

4.  **Create an Ansible Configuration File:**
    Create a file named `ansible.cfg` to tell Ansible where to find the inventory.
    ```ini
    [defaults]
    inventory = inventory.ini
    host_key_checking = False
    ```

---

## 4. Playbook 1: Discovering Network Devices

Our first task is to get a list of all network devices managed by DNA Center. This is a fundamental step in network automation, as it allows you to dynamically target devices for configuration or monitoring.

### 4.1. Create the Playbook

Create a file named `get_devices.yml` and add the following content.

```yaml
---
- name: Playbook 1 - Get Network Devices from Cisco DNA Center
  hosts: dnac
  gather_facts: no
  collections:
    - cisco.dnac

  tasks:
    - name: Get Network Device List
      network_device_info:
        dnac_host: "198.18.129.100"
        dnac_username: "admin"
        dnac_password: "C1sco12345"
        dnac_verify: false
      register: device_list

    - name: Print Device List
      debug:
        var: device_list.dnac_response
```

### 4.2. Execute the Playbook

Run the playbook from your terminal:
```bash
ansible-playbook get_devices.yml
```

### 4.3. Verify the Output

The playbook will print a JSON object containing a list of devices. This confirms that you have successfully connected to DNAC and retrieved data. The output will be large, but here is a sample of what one device entry might look like:

**Expected Output (Sample):**
```json
{
    "dnac_response": [
        {
            "family": "Switches and Hubs",
            "hostname": "cat9k-sw1.dcloud.cisco.com",
            "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
            "ipAddress": "192.168.1.10",
            "macAddress": "00:1A:2B:3C:4D:5E",
            "managementIpAddress": "192.168.1.10",
            "platformId": "C9300-48UXM",
            "reachabilityStatus": "Reachable",
            "role": "ACCESS",
            "softwareVersion": "17.3.3",
            "type": "Cisco Catalyst 9300 Switch",
            "upTime": "28 days, 11:14:01.68",
            "serialNumber": "FCW12345678"
        }
    ],
    "changed": false,
    "failed": false
}
```

---

## 5. Playbook 2: Checking Site Health

Now for a more advanced task. We will retrieve the health status of all sites configured in DNA Center. This is a common operational task for network monitoring and troubleshooting.

### 5.1. Create the Playbook

Create a new file named `get_site_health.yml`. This playbook uses the `site_health_info` module.

```yaml
---
- name: Playbook 2 - Get Site Health from Cisco DNA Center
  hosts: dnac
  gather_facts: no
  collections:
    - cisco.dnac

  tasks:
    - name: Get Site Health Information
      site_health_info:
        dnac_host: "198.18.129.100"
        dnac_username: "admin"
        dnac_password: "C1sco12345"
        dnac_verify: false
      register: site_health

    - name: Print Site Health
      debug:
        var: site_health.dnac_response
```

### 5.2. Execute the Playbook

Run the playbook from your terminal:
```bash
ansible-playbook get_site_health.yml
```

### 5.3. Verify the Output

The output will be a JSON object detailing the health scores for different categories (wired, wireless, etc.) for each site.

**Expected Output (Sample):**
```json
{
    "dnac_response": [
        {
            "clientHealthScore": [
                {
                    "healthScore": 10,
                    "scoreCategory": "WIRED",
                    "scoreValue": "POOR"
                }
            ],
            "networkHealthScore": [
                {
                    "healthScore": 10,
                    "scoreCategory": "ROUTER",
                    "scoreValue": "GOOD"
                },
                {
                    "healthScore": 10,
                    "scoreCategory": "ACCESS",
                    "scoreValue": "GOOD"
                }
            ],
            "siteName": "San Jose-1"
        }
    ],
    "changed": false,
    "failed": false
}
```

## 6. Optional Advanced Lab: Creating a CSV Template Report

In this advanced section, we will create a playbook that generates a CSV (Comma-Separated Values) report of all the configuration templates stored in DNA Center. This is a practical example of how Ansible can be used for auditing and documentation. We will use a Jinja2 template to format the template data into a CSV structure.

### 6.1. Understand the Jinja2 Template

We will create a new template, `templates_csv.j2`, to define the structure of our CSV report for the configuration templates.

**File: `templates_csv.j2`**
```jinja
Name,Project Name,Language,Last Update Time
{% for template in templates %}
"{{ template.name }}","{{ template.projectName }}",{{ template.language }},{{ template.lastUpdateTime }}
{% endfor %}
```
*   The first line defines the CSV header.
*   The `{% for template in templates %}` loop iterates over the list of templates passed from the playbook.
*   The line inside the loop formats each template's properties into a comma-separated line. We put quotes around the name and project name to handle potential commas in those fields.

### 6.2. Create the Playbook

Create a new file named `create_template_report.yml`. This playbook uses the `configuration_template_info` module to get a list of all templates and then uses the `template` module to render the Jinja2 template with that data.

```yaml
---
- name: Playbook 3 - Create a CSV Report of Configuration Templates
  hosts: dnac
  gather_facts: no
  connection: local
  collections:
    - cisco.dnac

  tasks:
    - name: Get Configuration Template List
      configuration_template_info:
        dnac_host: "198.18.129.100"
        dnac_username: "admin"
        dnac_password: "C1sco12345"
        dnac_verify: false
      register: template_list

    - name: Create CSV file from template
      template:
        src: templates_csv.j2
        dest: template_report.csv
      vars:
        templates: "{{ template_list.dnac_response }}"

    - name: Display report location
      debug:
        msg: "CSV report created at: template_report.csv"
```

### 6.3. Execute the Playbook

Run the playbook from your terminal:
```bash
ansible-playbook create_template_report.yml
```

### 6.4. Verify the Output

The playbook will create a new file named `template_report.csv` in your project directory. You can open this file with any text editor or spreadsheet program to see the formatted template inventory. Because the DNAC Sandbox has templates, you will see data in this report.

**Expected `template_report.csv` content (Sample):**
```csv
Name,Project Name,Language,Last Update Time
"Day-N Templates for SDA Fabric",SDA,VELOCITY,1678886400000
"Onboarding Template for SDA Fabric",SDA,VELOCITY,1678886400000
```

## 7. Conclusion

Congratulations! You have successfully used the Cisco DNAC Ansible Collection to perform key automation tasks, from device discovery and health checks to generating a formatted CSV report of configuration templates. You have seen how Ansible can simplify interactions with the DNA Center API and transform raw JSON data into useful, human-readable formats.

From here, you can explore other modules in the `cisco.dnac` collection to automate device provisioning, policy management, and more. This lab provides the foundation for building more complex and powerful network automation workflows.
