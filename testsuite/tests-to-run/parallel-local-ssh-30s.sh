#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par__test_ipv6_format() {
    # If not MaxStartups 100:30:1000 then this will fail
    ipv4() {
	ifconfig | perl -nE '/inet (\S+) / and say $1'
    }
    ipv6() {
	ifconfig | perl -nE '/inet6 ([0-9a-f:]+) .*(host|global)/ and say $1'
    }
    refresh_known_host() {
	ssh-keygen -f ~/.ssh/known_hosts -R "$@"
	ssh -oStrictHostKeyChecking=accept-new "$@" true
    }
    export -f refresh_known_host
    (ipv4; ipv6) | stdout parallel -j1 refresh_known_host >/dev//null
    echo '### Host as IPv6 address'
    (
	ipv6 |
            # Get IPv6 addresses of local server
            perl -nE '/([0-9a-f:]+)/ and
              map {say $1,$_,22; say $1,$_,"ssh"} qw(: . #  p q)' |
            # 9999::9999:9999:22 => [9999::9999:9999]:22
	    # 9999::9999:9999q22 => 9999::9999:9999
            perl -pe 's/(.*):(22|ssh)$/[$1]:$2/;s/q.*//;'
	ipv4 |
            # Get IPv4 addresses
            perl -nE '/(\S+)/ and
              map {say $1,$_,22; say $1,$_,"ssh"} qw(:  q)' |
            # 9.9.9.9q22 => 9.9.9.9
            perl -pe 's/q.*//;'
    ) |
	parallel -j50% --argsep , parallel -S {} true ::: 1 ||
	echo Failed
}


export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j300% --tag -k '{} 2>&1'
