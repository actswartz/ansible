#!/bin/bash
COMMAND="ansible-navigator inventory -i inventory.yml --list"
echo "Executing: $COMMAND"
$COMMAND
