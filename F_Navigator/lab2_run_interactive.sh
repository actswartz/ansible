#!/bin/bash
COMMAND="ansible-navigator run hello.yml -i inventory.yml"
echo "Executing: $COMMAND"
$COMMAND