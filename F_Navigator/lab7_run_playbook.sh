#!/bin/bash
set -e

VAULT_PASSWORD="a_simple_password"
VAULT_PASS_FILE=".vault_pass"

# Create a temporary vault password file
echo "$VAULT_PASSWORD" > "$VAULT_PASS_FILE"

COMMAND="ansible-navigator run vault_playbook.yml -i inventory.yml --vault-password-file $VAULT_PASS_FILE"
echo "Executing: $COMMAND"
$COMMAND --mode stdout

# Clean up temporary file
rm "$VAULT_PASS_FILE"
