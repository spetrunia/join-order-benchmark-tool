#!/bin/bash

set -e

bash check-dump-available.sh
bash setup-server/setup-mariadb-current.sh bb-11.0
bash test-harness/10-load-data-dump.sh
bash test-harness/50-eits-analyze.sh
#bash test-harness/20-generate-workload.sh
bash test-harness/100-generate-detailed-workload.sh
bash tmp-mariadb/run-queries-analyze/run.sh
bash test-harness/40-save-result.sh
