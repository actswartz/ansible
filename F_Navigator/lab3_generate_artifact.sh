#!/bin/bash
COMMAND="ansible-navigator run hello.yml -i inventory.yml"
echo "Executing: $COMMAND to generate artifact."
$COMMAND