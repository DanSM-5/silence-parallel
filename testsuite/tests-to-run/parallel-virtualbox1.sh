#!/bin/bash

stdout ping -w 1 -c 1 centos3 >/dev/null || (
    # Vagrant does not set the IP addr
    cd testsuite/vagrant/tange/centos3/ 2>/dev/null
    cd vagrant/tange/centos3/ 2>/dev/null
    cd ../vagrant/tange/centos3/ 2>/dev/null
    stdout vagrant up >/dev/null
    vagrant ssh -c 'sudo ifconfig eth1 172.27.27.3' |
	# Ignore empty ^M line
	grep ..
)

stdout parallel --tag -k 'ping -w 1 -c 1 {} || (cd vagrant/*/{} && vagrant up)' ::: rhel8 centos3 |
	grep -v 'default' | grep -v '==>' | grep -E '^$' &

wssh vagrant@rhel8 true
wssh vagrant@centos3 true

par_warning_on_centos3() {
    echo "### bug #37589: Red Hat 9 (Shrike) perl v5.8.0 built for i386-linux-thread-multi error"
    testone() {
	sshlogin="$1"
	program="$2"
	basename="$3"
	scp "$program" "$sshlogin":/tmp/"$basename"
	stdout ssh "$sshlogin" perl /tmp/"$basename" echo \
	       ::: Old_must_fail_New_must_be_OK
    }
    export -f testone
    parallel --tag -k testone {1} {2} {2/} \
	     ::: vagrant@centos3 vagrant@rhel8 \
	     ::: /usr/local/bin/parallel-20120822 `which parallel`
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | LC_ALL=C sort |
    parallel --timeout 1000% -j6 --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1' |
    perl -pe 's:/usr/bin:/bin:g;'

(
    cd vagrant/tange/centos3/
    stdout vagrant suspend |
	grep -v '==> default: Saving VM state' |
	grep -v 'An action .suspend. was attempted on the machine .default.,' |
	grep -v 'but another process is already executing an action on the machine.' |
	grep -v 'Vagrant locks each machine for access by only one process at a time.' |
	grep -v 'Please wait until the other Vagrant process finishes modifying this' |
	grep -v 'machine, then try again.' |
	grep -v 'If you believe this message is in error, please check the process' |
	grep -v 'listing for any "ruby" or "vagrant" processes and kill them. Then' |
	grep -v 'try again.' |
	grep .
)
