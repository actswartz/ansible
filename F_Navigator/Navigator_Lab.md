# Ansible Navigator

## Introduction

If you've used `ansible-playbook` before, you're familiar with running Ansible automation from the command line. **ansible-navigator** is a next-generation, text-based user interface (TUI) for running and developing Ansible content. It enhances the user experience by providing a more interactive and consistent way to execute automation.

### Why use ansible-navigator?

* **Interactive TUI:** Instead of a long scroll of text, you get a navigable interface where you can inspect every task, play, and host in detail.
* **Execution Environments (EEs):** It runs Ansible content within containerized Execution Environments. This ensures that your automation runs with the exact same dependencies (Python version, libraries, collections) every single time, whether on your laptop or in a CI/CD pipeline.
* **Artifacts:** Every playbook run creates a detailed artifact file. You can "replay" this artifact later to review the entire run without connecting to the target hosts again.
* **Better Experience:** It provides rich data, easy navigation, and helpful commands for inspecting your Ansible setup.

This lab book will guide you through installing and using **ansible-navigator** for your automation tasks.

---

## Lab 1: Verifying Setup and First Run

### Objective

Verify your `ansible-navigator` installation, install a container engine, and run a simple ad-hoc command to confirm the setup.

### Background

`ansible-navigator` relies on a container engine (like Podman or Docker) to pull and run Execution Environments. We’ll use Podman in these examples.

### Pre-requisites

* A Linux system or WSL2 on Windows.
* `sudo` or root access to install packages.

### Exercise

**Install a container engine (Podman):[--- THIS IS ALREADY BEEN DONE ---]**

```bash
# For Fedora/CentOS/RHEL
sudo dnf install podman

# For Debian/Ubuntu
sudo apt-get update && sudo apt-get install podman
```

**Create a simple inventory file:**

Create a file named `inventory.yml`:

```yaml
---
all:
  hosts:
    localhost:
      ansible_connection: local
```

**Run your first command:**

```bash
ansible-navigator exec -- ansible localhost -m ping -i inventory.yml --mode stdout
```

The first run will pull the default Execution Environment image.

### Expected Outcome

You will see a JSON output with a "ping" value of "pong", indicating a successful connection.
```json
{
    "changed": false,
    "ping": "pong"
}
```

### Questions

1. What is the purpose of `ansible_connection: local` in the inventory?
2. How can you see which container image was used for the run?

---

## Lab 2: Running a Playbook and Navigating the TUI

### Objective

Execute a basic playbook and learn to navigate the TUI.

### Exercise

**Create a simple playbook file `hello.yml`:**

```yaml
---
- name: A simple test playbook
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Task 1 - Print a message
      ansible.builtin.debug:
        msg: "Hello from Ansible Navigator!"

    - name: Task 2 - Show date
      ansible.builtin.command: "date"
      register: date_result

    - name: Task 3 - Display date
      ansible.builtin.debug:
        var: date_result.stdout
```

**Run the playbook:**

```bash
# Stdout mode
ansible-navigator run hello.yml -i inventory.yml --mode stdout

# Interactive TUI
ansible-navigator run hello.yml -i inventory.yml
```

**Navigate the TUI:**

* Press `0` to jump to the first task.
* Press `Enter` to expand host details.
* Use arrow keys to scroll.
* Press `ESC` to go back.

### Questions

1. How do you view the detailed output of “Task 2 - Show uptime”?
2. What’s the difference between running with and without `--mode stdout`?

---

## Lab 3: Exploring with ansible-navigator replay

### Objective

Use the replay subcommand to review a previous playbook run.

### Exercise

**Note:** Playbook artifacts are not enabled by default. Before running the command, ensure you have an `ansible-navigator.yml` file and add the following content to enable artifact creation:

```yaml
---
ansible-navigator:
  playbook-artifact:
    enable: true
```

Run a playbook to generate an artifact:

```bash
ansible-navigator run hello.yml -i inventory.yml
```

Replay the artifact (replace with your filename):

```bash
ansible-navigator replay ansible-navigator-artifact-<timestamp>.json
```

### Questions

1. What’s the main advantage of replaying an artifact vs. stdout logs?
2. Does replay reconnect to hosts?

---

## Lab 4: Inspecting Your Configuration

### Objective

View current settings, explore inventory, and check installed collections.

### Exercise

```bash
ansible-navigator settings
ansible-navigator inventory -i inventory.yml --list
ansible-navigator collections
```

### Questions

1. What is the default value of `playbook-artifact-enable`?
2. How would you view host variables in a large inventory?

---

## Lab 5: Customizing Execution Environments

### Objective

Use a custom Execution Environment for predictable automation.

### Exercise

Create `ansible-navigator.yml`:

```yaml
---
ansible-navigator:
  execution-environment:
    image: "ghcr.io/ansible/creator-ee:v0.12.0"
    pull:
      policy: missing
```

Run playbook with the custom EE:

```bash
ansible-navigator run hello.yml -i inventory.yml
```

### Questions

1. Why is versioning EEs important?
2. How can you configure `ansible-navigator`?

---

## Lab 6: Using doc for In-Terminal Documentation

```bash
ansible-navigator doc ansible.builtin.debug
ansible-navigator doc ansible.builtin.apt
```

### Questions

1. What is the type of the `msg` parameter in `debug`?
2. Why is `doc` better than web searching?

---

## Lab 7: Integrating with Ansible Vault

### Exercise

**Note:** The `ansible-vault create` command opens an editor and is difficult to use in scripts. The following method is more automation-friendly.

**1. Create a plaintext secrets file:**

Create a file named `secrets.plain.yml`:
```yaml
---
api_key: "abc123-def456-789-xyz"
db_password: "super_secret_password"
```

**2. Create a vault password file:**

Create a file named `.vault_pass` with your desired password. For this lab, we'll use `a_simple_password`.
```bash
echo "a_simple_password" > .vault_pass
```
*Note: In a real project, be sure to add `.vault_pass` to your `.gitignore` file to avoid committing it.*

**3. Encrypt the secrets file:**

Use `ansible-vault` to encrypt the plaintext file.
```bash
ansible-vault encrypt secrets.plain.yml --vault-password-file .vault_pass --output secrets.yml
```
Now you have an encrypted `secrets.yml` file. You can safely delete `secrets.plain.yml`.

**4. Create the playbook `vault_playbook.yml`:**

```yaml
---
- name: Test using vault secrets
  hosts: localhost
  gather_facts: false
  vars_files:
    - secrets.yml
  tasks:
    - name: Display the secret API key
      ansible.builtin.debug:
        msg: "The API key is {{ api_key }}"
```

**5. Run the playbook:**

Provide the vault password file to run the playbook non-interactively.
```bash
ansible-navigator run vault_playbook.yml -i inventory.yml --vault-password-file .vault_pass
```

### Questions

1. What happens if you enter the wrong Vault password?
2. How can you supply the password non-interactively?


