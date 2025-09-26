#!/bin/bash
rm -f /tmp/my-artifact.json
COMMAND="ansible-navigator run hello.yml -i inventory.yml --mode stdout --playbook-artifact-save-as /tmp/my-artifact.json"
echo "Executing: $COMMAND to generate artifact."
$COMMAND
