#!/bin/bash
COMMAND="ansible-navigator exec -- ansible localhost -m ping -i inventory.yml"
echo "Executing: $COMMAND"
$COMMAND