#!/bin/bash
LATEST_ARTIFACT=$(ls -t ansible-navigator-artifact-*.json | head -n 1)
if [ -z "$LATEST_ARTIFACT" ]; then
  echo "Error: No artifact file found."
  exit 1
fi
COMMAND="ansible-navigator replay \$LATEST_ARTIFACT --mode stdout"
echo "Executing: $COMMAND"
ansible-navigator replay "$LATEST_ARTIFACT" --mode stdout
