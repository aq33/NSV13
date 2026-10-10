#!/bin/bash
set -euo pipefail
EXIT_CODE=0

tools/deploy.sh ci_test
mkdir ci_test/config

# AQUILA - caly katalog config: kod czyta wiele plikow bezposrednio (filtry, listy imion, starmap),
# a testy powinny widziec to samo co serwer. config.txt jest potem nadpisany wersja testowa.
cp -r config/. ci_test/config/

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt

cd ci_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
DreamDaemon nsv13.dmb -close -trusted -verbose -params "log-directory=ci" || EXIT_CODE=$?

cd ..
cat ci_test/data/logs/ci/clean_run.lk
