#!/bin/bash
# This is the entrypoint for "data" container.
# It calls the prepare_script.sh and then launches the original entrypoint

# Prepare data
/data_assets/prepare_data.sh

# Original entrypoint script
/scripts/docker-entrypoint.sh
