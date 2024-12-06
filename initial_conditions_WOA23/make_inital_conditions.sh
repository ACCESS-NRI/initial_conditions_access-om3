#!/bin/bash

# Check if a resolution is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <resolution>"
    echo "Valid resolutions: 01, 025, 10"
    exit 1
fi

# Assign the provided resolution to a variable
RESOLUTION="$1"

# Validate the resolution
if [[ "$RESOLUTION" != "01" && "$RESOLUTION" != "025" && "$RESOLUTION" != "10" ]]; then
    echo "Invalid resolution: $RESOLUTION"
    echo "Valid resolutions are: 01, 025, 10"
    exit 1
fi

# Execute make_initial_conditions.sh with the specified resolution

cd $RESOLUTION && qsub make_ic
