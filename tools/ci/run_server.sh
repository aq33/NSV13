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
# AQUILA - DreamDaemon 516 na Linuksie potrafi wisiec kilka minut po "Shutdown complete",
# chociaz swiat jest juz zamkniety, a wynik zapisany w clean_run.lk. Na 515 wychodzil od razu.
# Odpalamy go w tle, a gdy po zamknieciu swiata nie wyjdzie sam w ciagu SHUTDOWN_GRACE sekund, zabijamy go.
SHUTDOWN_GRACE=15
DreamDaemon nsv13.dmb -close -trusted -verbose -params "log-directory=ci" > dd_output.log 2>&1 &
DD_PID=$!
tail -n +1 -f dd_output.log --pid=$DD_PID &
TAIL_PID=$!

while kill -0 $DD_PID 2>/dev/null; do
	if grep -q "Shutdown complete" dd_output.log; then
		for _ in $(seq 1 $SHUTDOWN_GRACE); do
			kill -0 $DD_PID 2>/dev/null || break
			sleep 1
		done
		if kill -0 $DD_PID 2>/dev/null; then
			echo "DreamDaemon nie wyszedl ${SHUTDOWN_GRACE}s po zamknieciu swiata, zabijam go."
			kill $DD_PID 2>/dev/null || true
			sleep 2
			kill -9 $DD_PID 2>/dev/null || true
		fi
		break
	fi
	sleep 1
done

wait $DD_PID || EXIT_CODE=$?
wait $TAIL_PID 2>/dev/null || true

cd ..
cat ci_test/data/logs/ci/clean_run.lk
