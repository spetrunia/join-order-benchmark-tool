#!/bin/bash

set -e

bash setup-server/setup-mariadb-current.sh 12.2
bash test-harness/01-setup.sh
bash test-harness/10-load-data.sh
bash test-harness/20-generate-workload.sh
bash test-harness/50-eits-analyze.sh
bash test-harness/30-run-workload.sh
bash test-harness/40-save-result.sh
