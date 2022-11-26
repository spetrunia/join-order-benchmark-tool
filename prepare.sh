#!/bin/bash

# This script prepares the dataset from the original CSV files.
# This involves loading them into PostgreSQL, dumping back,
# and makng some edits.
#
# For MariaDB, consider using pre-made dump (check-dump.sh)

bash test-harness/000-setup-dataset.sh
