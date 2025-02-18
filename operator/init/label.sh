#!/bin/bash

# Set the source and target label keys
SOURCE_LABEL_KEY="node_pool"
TARGET_LABEL_KEY="node"

# Get all node names
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

# Loop through each node
for NODE in $NODES
do
    # Get the value of the source label
    LABEL_VALUE=$(kubectl get node $NODE -o jsonpath="{.metadata.labels.$SOURCE_LABEL_KEY}")
    
    # Check if the source label exists
    if [ -n "$LABEL_VALUE" ]; then
        echo "Copying label for node $NODE: $SOURCE_LABEL_KEY=$LABEL_VALUE to $TARGET_LABEL_KEY=$LABEL_VALUE"
        
        # Set the new label with the fetched value
        kubectl label node $NODE $TARGET_LABEL_KEY=$LABEL_VALUE --overwrite
    else
        echo "Source label $SOURCE_LABEL_KEY not found on node $NODE. Skipping."
    fi
done

echo "Label copying process completed."