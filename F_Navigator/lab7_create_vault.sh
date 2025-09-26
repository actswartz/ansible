#!/bin/bash
set -e

VAULT_PASSWORD="a_simple_password"
SECRETS_PLAIN="secrets.plain.yml"
SECRETS_ENCRYPTED="secrets.yml"
VAULT_PASS_FILE=".vault_pass"

# Create the plaintext secrets file
cat > "$SECRETS_PLAIN" << EOF
---
api_key: "abc123-def456-789-xyz"
db_password: "super_secret_password"
EOF

# Create a temporary vault password file
echo "$VAULT_PASSWORD" > "$VAULT_PASS_FILE"

echo "Encrypting $SECRETS_PLAIN into $SECRETS_ENCRYPTED..."
ansible-vault encrypt "$SECRETS_PLAIN" --vault-password-file "$VAULT_PASS_FILE" --output "$SECRETS_ENCRYPTED"

# Clean up temporary files
rm "$SECRETS_PLAIN"
rm "$VAULT_PASS_FILE"

echo "Successfully created encrypted vault file: $SECRETS_ENCRYPTED"
