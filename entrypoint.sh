#!/bin/bash

# Initialize conda
source /opt/conda/etc/profile.d/conda.sh
conda activate IgGM

# Execute the passed command
exec "$@"

