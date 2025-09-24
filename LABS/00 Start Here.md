You need an SSH tool…. Click Start \> type Powershell (CLI)

ssh [ngc@go.nr4.com](mailto:ngc@go.nr4.com)

password: [instructor]

cd ‘your_directory’

mkdir wed

cd wed

nano inventory.txt

(Make it look like the below, but change the last octet of the IP address to match your device.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
10.10.20.212 ansible_user=cisco ansible_password=cisco 

[csr]
10.10.20.212

[csr:vars]
ansible_connection=network_cli
ansible_network_os=ios
ansible_command_timeout=120

[all:vars]
ansible_python_interpreter=/usr/bin/python3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We will be doing labs 8-11.

<https://github.com/actswartz/ansible/blob/main/LABS/08%20Loops%20-%20Loop.md>

<https://github.com/actswartz/ansible/blob/main/LABS/09%20Loop%20Control.md>

<https://github.com/actswartz/ansible/blob/main/LABS/10%20Conditionals.md>

<https://github.com/actswartz/ansible/blob/main/LABS/11%20JINJA%202%20Templating.md>

