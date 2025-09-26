#!/bin/bash
COMMAND="ansible-navigator run hello.yml -i inventory.yml"
echo "Executing: $COMMAND"
echo "Note: This would normally open the interactive TUI. For this script, we'll run in stdout mode."
$COMMAND --mode stdout
