#!/usr/bin/env ksh

# This file must be sourced in ksh:
#
#   source `which env_parallel.ksh`
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2016,2017
# Ole Tange and Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>
# or write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301 USA

env_parallel() {
    # env_parallel.ksh

    _names_of_ALIASES() {
	alias | perl -pe 's/=.*//'
    }
    _bodies_of_ALIASES() {
	alias "$@" | perl -pe 's/^/alias /'
    }
    _names_of_maybe_FUNCTIONS() {
	true not used
    }
    _names_of_FUNCTIONS() {
	typeset +p -f | perl -pe 's/\(\).*//'
    }
    _bodies_of_FUNCTIONS() {
	typeset -f "$@"
    }
    _names_of_VARIABLES() {
	typeset +p | perl -pe 's/^typeset .. //'
    }
    _bodies_of_VARIABLES() {
	typeset -p "$@"
    }
    _remove_bad_NAMES() {
	# Do not transfer vars and funcs from env_parallel
	grep -Ev '^(_names_of_ALIASES|_bodies_of_ALIASES|_names_of_maybe_FUNCTIONS|_names_of_FUNCTIONS|_bodies_of_FUNCTIONS|_names_of_VARIABLES|_bodies_of_VARIABLES|_remove_bad_NAMES|_prefix_PARALLEL_ENV|_get_ignored_VARS|_make_grep_REGEXP|_ignore_UNDERSCORE|_alias_NAMES|_list_alias_BODIES|_function_NAMES|_list_function_BODIES|_variable_NAMES|_list_variable_VALUES|_prefix_PARALLEL_ENV|PARALLEL_TMP)$' |
	    # Filter names matching --env
	    grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ |
	    # Vars set by /bin/sh
            grep -Ev '^(_)$'
    }

    _get_ignored_VARS() {
        perl -e '
            for(@ARGV){
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env=/^--env$/;
            }
            if(grep { /^_$/ } @envvar) {
                if(not open(IN, "<", "$ENV{HOME}/.parallel/ignored_vars")) {
             	    print STDERR "parallel: Error: ",
            	    "Run \"parallel --record-env\" in a clean environment first.\n";
                } else {
            	    chomp(@ignored_vars = <IN>);
            	    $vars = join "|",map { quotemeta $_ } "env_parallel", @ignored_vars;
		    print $vars ? "($vars)" : "(,,nO,,VaRs,,)";
                }
            }
            ' -- "$@"
    }

    # Get the --env variables if set
    # --env _ should be ignored
    # and convert  a b c  to (a|b|c)
    # If --env not set: Match everything (.*)
    _make_grep_REGEXP() {
        perl -e '
            for(@ARGV){
                /^_$/ and $next_is_env = 0;
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env = /^--env$/;
            }
            $vars = join "|",map { quotemeta $_ } @envvar;
            print $vars ? "($vars)" : "(.*)";
            ' -- "$@"
    }

    if which parallel | grep 'no parallel in' >/dev/null; then
	echo 'env_parallel: Error: parallel must be in $PATH.' >&2
	return 255
    fi
    if which parallel >/dev/null; then
	true which on linux
    else
	echo 'env_parallel: Error: parallel must be in $PATH.' >&2
	return 255
    fi

    # Grep regexp for vars given by --env
    _grep_REGEXP="`_make_grep_REGEXP \"$@\"`"

    # Deal with --env _
    _ignore_UNDERSCORE="`_get_ignored_VARS \"$@\"`"

    # --record-env
    if perl -e 'exit grep { /^--record-env$/ } @ARGV' -- "$@"; then
	true skip
    else
	(_names_of_ALIASES;
	 _names_of_FUNCTIONS;
	 _names_of_VARIABLES) |
	    cat > $HOME/.parallel/ignored_vars
	return 0
    fi

    # Grep alias names
    _alias_NAMES="`_names_of_ALIASES | _remove_bad_NAMES`"
    _list_alias_BODIES="_bodies_of_ALIASES $_alias_NAMES"
    if [ "$_alias_NAMES" = "" ] ; then
	# no aliases selected
	_list_alias_BODIES="true"
    fi
    unset _alias_NAMES

    # Grep function names
    _function_NAMES="`_names_of_FUNCTIONS | _remove_bad_NAMES`"
    _list_function_BODIES="_bodies_of_FUNCTIONS $_function_NAMES"
    if [ "$_function_NAMES" = "" ] ; then
	# no functions selected
	_list_function_BODIES="true"
    fi
    unset _function_NAMES

    # Grep variable names
    _variable_NAMES="`_names_of_VARIABLES | _remove_bad_NAMES`"
    _list_variable_VALUES="_bodies_of_VARIABLES $_variable_NAMES"
    if [ "$_variable_NAMES" = "" ] ; then
	# no variables selected
	_list_variable_VALUES="true"
    fi
    unset _variable_NAMES

    PARALLEL_ENV="`
        $_list_alias_BODIES;
        $_list_function_BODIES;
        $_list_variable_VALUES;
    `"
    export PARALLEL_ENV
    unset _list_alias_BODIES
    unset _list_variable_VALUES
    unset _list_function_BODIES
    # Test if environment is too big
    if `which true` >/dev/null ; then
	`which parallel` "$@";
	_parallel_exit_CODE=$?
	unset PARALLEL_ENV;
	return $_parallel_exit_CODE
    else
	unset PARALLEL_ENV;
	echo "env_parallel: Error: Your environment is too big." >&2
	echo "env_parallel: Error: Try running this in a clean environment once:" >&2
	echo "env_parallel: Error:   env_parallel --record-env" >&2
	echo "env_parallel: Error: And the use '--env _'" >&2
	echo "env_parallel: Error: For details see: man env_parallel" >&2

	return 255
    fi
}
