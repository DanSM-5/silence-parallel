# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

### Full test set (except mem)
testsuite: short
	true

all: mem short long polar 
	true

3: ../src/parallel tests-to-run/* wanted-results/* startdb prereqlocal prereqremote
	TRIES=3 time bash Start.sh '' mem || true
	touch ~/.parallel/will-cite
	make stopvm

1: ../src/parallel tests-to-run/* wanted-results/* prereqlocal startdb prereqremote
	TRIES=1 time bash Start.sh '' mem || true
	touch ~/.parallel/will-cite
	make stopvm

# Mem
mem: ../src/parallel tests-to-run/*mem* wanted-results/*mem*
	make stopvm || true
	make stopdb || true
	time bash Start.sh mem NONE || true
	touch ~/.parallel/will-cite
	make stopvm

# The output must be inspected visually
manual: ../src/parallel tests-to-run/*manual* wanted-results/*manual*
	bash tests-to-run/parallel-manual.sh

# Tutorial
tutorial: ../src/parallel tests-to-run/*tutorial* wanted-results/*tutorial* prereqlocal
	TRIES=1 time bash Start.sh tutorial NONE || true
	touch ~/.parallel/will-cite
	make stopvm

# 100s and 300s
100s: ../src/parallel tests-to-run/*00s* wanted-results/*00s* prereqlocal
	time bash Start.sh 00s NONE || true
	touch ~/.parallel/will-cite
	make stopvm

# Polarhome
polarhome: polar
	true

polar: ../src/parallel tests-to-run/*polar* wanted-results/*polar* prereqlocal
	time bash Start.sh polar NONE || true
	touch ~/.parallel/will-cite

# *local* only
local:	../src/parallel tests-to-run/*local* wanted-results/*local* prereqlocal installparallel
	time bash Start.sh local mem

# short
short:	 ../src/parallel tests-to-run/* wanted-results/* prereqlocal installparallel
	TRIES=1 time bash Start.sh '' 'polar|mem|100s|300s|manual'

# long
long:	 ../src/parallel tests-to-run/* wanted-results/* prereqlocal installparallel
	TRIES=1 time bash Start.sh '00s' NONE

# short and local
localshort: ../src/parallel tests-to-run/*local* wanted-results/*local* prereqlocal installparallel
	TRIES=1 time bash Start.sh local 'mem|100s|300s'

# sql
testdb: ../src/parallel tests-to-run/*sql* wanted-results/*sql* prereqdb
	time bash Start.sh sql NONE

# Portable tests that run everywhere
portable:
	# Cache sudo password
	sudo echo
	time bash Portable.sh

### Prerequisites
REQUIRE=bash -c '\
  is_installed() { \
    eval $$2 >/dev/null 2>/dev/null || (echo "$$1" is required for testsuite; /bin/false); \
  }; \
  export -f is_installed; \
  parallel -n2 --tag is_installed ::: \
	script		"echo | script -c echo -q /dev/null"			\
	"ssh sh@lo"	"timeout 20 ssh sh@lo true"				\
	"ssh csh@lo"	"timeout 5 ssh csh@lo true"				\
	niceload	"niceload echo niceload is installed"			\
	expect	"expect -c \"spawn cat; puts \\\"expect is installed\\\"\"" 	\
	autossh		"autossh -V"						\
	tcsh		"tcsh -c echo tcsh installed"				\
	seq		"seq 1 2"						\
	stdout		"stdout echo stdout is installed"			\
	convert		"convert -version"					\
	bc		"echo 1+2 | bc"						\
	gawk		"echo | gawk \"{print \\\"gawk is installed\\\"}\""	\
	pv		"echo | pv -qL 10"					\
	timeout		"timeout 1 echo timeout is installed"			\
	sshpass		"sshpass echo sshpass is installed"			\
'
#	lsh	"lsh lo echo lsh is installed"					\

prereqlocal: installparallel startvm
	${REQUIRE}
	(parallel 'ssh -oStrictHostKeyChecking=accept-new vagrant@parallel-server{} mkdir -p bin; scp `which parallel` vagrant@parallel-server{}:bin/' ::: 1 2 3 4)&

prereqremote: installparallel startvm
	parallel -j0 --timeout 10 --tag ssh -oStrictHostKeyChecking=accept-new vagrant@parallel-server{} parallel --minversion 20121021 ::: 1 2 || (echo parallel on remote required for testsuite; /bin/true)

ignore=bytes.of.data|ping.statistics|packets.transmitted|64.bytes.from|\
  min/avg/max/mdev|default|known.hosts|Host.*found
start=(stdout ping -w 1 -c 1 {} && ssh vagrant@{} echo ssh {} works || \
  (cd vagrant/*/{} 2>/dev/null && vagrant up ; \
   echo {} | grep -q centos3 && \
    (cat ../../authorized_keys | vagrant ssh -c "cat >>.ssh/authorized_keys"; \
     vagrant ssh -c "sudo /sbin/ifconfig eth1 172.27.27.3"); \
   ssh-keygen -R {}; \
   stdout wssh -oStrictHostKeyChecking=accept-new vagrant@{} echo ssh {} started and works) ) | \
  grep -Ev "${ignore}"

stop=(stdout ping -w 1 -c 1 {} && \
  (cd vagrant/*/{} && vagrant suspend) ) | \
  grep -Ev "${ignore}"

namedservers=centos9 freebsd13 freebsd14 rhel8 centos3 openindiana centos8
servers=parallel-server1 parallel-server2 parallel-server3 parallel-server4 ${namedservers}

startvm:
	sort -u ~/.ssh/*.pub vagrant/authorized_keys > vagrant/authorized_keys.
	mv vagrant/authorized_keys. vagrant/authorized_keys
	parallel -j0 --tag -k --timeout 100 '${start}' ::: ${servers} &
stopvm:
	parallel -j0 --tag -k '${stop}' ::: ${namedservers} || true

startdb:
	sql oracle://SYSTEM:$$VM_ORACLE_PWD@/FREE "select 'Oracle is running' from dual;" || \
	  (cd vagrant-projects/OracleDatabase/23.3.0-Free && vagrant up && \
	   sql oracle://SYSTEM:$$VM_ORACLE_PWD@/FREE "select 'Oracle is running' from dual;")
stopdb:
	cd vagrant-projects/OracleDatabase/23.3.0-Free; vagrant suspend

### Distribution
installparallel: ../src/parallel
	cd .. && make -j && sudo make -j install

clean:
	rm -rf input-files/random_dirs_no_newline
	rm -rf input-files/random_dirs_with_newline

dist:
	rm -rf input-files/random_dirs_*_newline || /bin/true
	rm -rf tmp || /bin/true
	( cd ..; tar -cvj --exclude .git --exclude '#*#' --exclude '*~' --exclude CVS -f /tmp/parallel.tar.bz2 parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] )
	mv /tmp/parallel.tar.bz2 parallel-$$(date +"%Y%m%d").tar.bz2
	rsync -Havessh parallel-$$(date +"%Y%m%d").tar.bz2 download.savannah.nongnu.org:/releases/parallel/

### Measure timings
timings: tests-to-run/* ../src/parallel
	ls tests-to-run/*.sh | parallel echo /usr/bin/time -f "'%e\ %P'" bash >/tmp/timing.script
	stdout bash -x /tmp/timing.script | tee /tmp/timing.out
	echo + .usr.bin.time_END >>/tmp/timing.out
	perl -ne '/\+ .usr.bin.time/ and do { print $$last.$$h; $$h=$$_ }; chomp; s/.*\0//;$$last = $$_' /tmp/timing.out |sort -n >timings

timingbar:
	vmstat 1 | timestamp --isotime > vmstat.timestamp.1 &
	stdout make 1 | timestamp --isotime | tee make.timestamp.1
	killall vmstat
	mv vmstat.timestamp.1 vmstat.timestamp
	mv make.timestamp.1 make.timestamp
	sort vmstat.timestamp make.timestamp | perl -pe '/tests-to-run(\S+)/ and $$p=$$1; print "$$p "' | field 6,1,2 | perl -ne '/^\d+ / and print' | histogram -i vh
