#!/bin/bash
set -euo pipefail
EXIT_CODE=0

tools/deploy.sh ci_test
mkdir ci_test/config

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt
# AQUILA - read by the Chrono Legionnaire unit test
cp config/chrono_legionnaire_names.txt ci_test/config/chrono_legionnaire_names.txt

cd ci_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
DreamDaemon nsv13.dmb -close -trusted -verbose -params "log-directory=ci" || EXIT_CODE=$?

cd ..
cat ci_test/data/logs/ci/clean_run.lk
