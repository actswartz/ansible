#!/bin/bash
COMMAND="ansible-navigator run hello.yml -i inventory.yml --mode stdout"
echo "Executing: $COMMAND"
$COMMAND
