#!/bin/bash
ARTIFACT_FILE="/tmp/my-artifact.json"
if [ ! -f "$ARTIFACT_FILE" ]; then
  echo "Error: Artifact file not found at $ARTIFACT_FILE"
  exit 1
fi
COMMAND="ansible-navigator replay \$ARTIFACT_FILE --mode stdout"
echo "Executing: $COMMAND"
ansible-navigator replay "$ARTIFACT_FILE" --mode stdout