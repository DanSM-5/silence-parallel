#!/bin/bash

# SPDX-FileCopyrightText: 2021-2022 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

tmp="$(mktemp -d)"
# Test with tmpdir with spaces
TMPDIR="$tmp/   "
export TMPDIR
mkdir -p "$TMPDIR"

par_basic_shebang_wrap() {
    echo "### Test basic --shebang-wrap"
    script="$TMPDIR"/basic--shebang-wrap
    cat <<EOF > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl

print "Shebang from perl with args @ARGV\n";
EOF

    chmod 755 "$script"
    args() { echo arg1; echo arg2; echo "arg3.1  arg3.2"; }
    "$script" "$(args)"
    echo "### Test basic --shebang-wrap Same as"
    parallel -k /usr/bin/perl "'$script'" ::: "$(args)"
    echo "### Test basic --shebang-wrap stdin"
    args | "$script"
    echo "### Test basic --shebang-wrap Same as"
    args | parallel -k /usr/bin/perl "'$script'"
    rm "$script"
}

par_shebang_with_parser_options() {
    seq 1 2 >/tmp/in12
    seq 4 5 >/tmp/in45
    
    echo "### Test --shebang-wrap with parser options"
    script="$TMPDIR"/with-parser--shebang-wrap
    cat <<EOF > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl -p

print "Shebang from perl with args @ARGV\n";
EOF

    chmod 755 "$script"
    "$script" /tmp/in12 /tmp/in45
    echo "### Test --shebang-wrap with parser options Same as"
    parallel -k /usr/bin/perl -p "'$script'" ::: /tmp/in12 /tmp/in45
    echo "### Test --shebang-wrap with parser options stdin"
    (echo /tmp/in12; echo /tmp/in45) | "$script"
    echo "### Test --shebang-wrap with parser options Same as"
    (echo /tmp/in12; echo /tmp/in45) | parallel -k /usr/bin/perl "'$script'"
    rm "$script"

    echo "### Test --shebang-wrap --pipe with parser options"
    script="$TMPDIR"/pipe--shebang-wrap
    cat <<EOF > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k --pipe /usr/bin/perl -p

print "Shebang from perl with args @ARGV\n";
EOF

    chmod 755 "$script"
    echo "### Test --shebang-wrap --pipe with parser options stdin"
    cat /tmp/in12 /tmp/in45 | "$script"
    echo "### Test --shebang-wrap --pipe with parser options Same as"
    cat /tmp/in12 /tmp/in45 | parallel -k --pipe /usr/bin/perl\ -p "'$script'"
    rm "$script"
    
    rm /tmp/in12
    rm /tmp/in45
}

par_shebang_wrap_perl() {
    script="$TMPDIR"/shebang_wrap_perl
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl

print "Arguments @ARGV\n";
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_python() {
    script="$TMPDIR"/shebang_wrap_python
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/python3

import sys
sys.argv.pop(0)
print('Arguments', str(sys.argv))
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_bash() {
    script="$TMPDIR"/shebang_wrap_bash
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /bin/bash

echo Arguments "$@"
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_sh() {
    script="$TMPDIR"/shebang_wrap_sh
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /bin/sh

echo Arguments "$@"
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_ksh() {
    script="$TMPDIR"/shebang_wrap_ksh
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/ksh

echo Arguments "$@"
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_zsh() {
    script="$TMPDIR"/shebang_wrap_zsh
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/zsh

echo Arguments "$@"
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_csh() {
    script="$TMPDIR"/shebang_wrap_csh
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /bin/csh

echo Arguments "$argv"
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_tcl() {
    script="$TMPDIR"/shebang_wrap_tcl
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/tclsh

puts "Arguments $argv"
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_R() {
    # Rscript fucks up if $TMPDIR contains space
    TMPDIR=/tmp
    script="$TMPDIR"/shebang_wrap_R
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/Rscript --vanilla --slave

args <- commandArgs(trailingOnly = TRUE)
print(paste("Arguments ",args))
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}


par_shebang_wrap_gnuplot() {
    script="$TMPDIR"/shebang_wrap_gnuplot
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k ARG={} /usr/bin/gnuplot

print "Arguments ", system('echo $ARG')
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_ruby() {
    script="$TMPDIR"/shebang_wrap_ruby
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/ruby
  
print "Arguments "
puts ARGV
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_octave() {
    script="$TMPDIR"/shebang_wrap_octave
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/octave

printf ("Arguments");
arg_list = argv ();
for i = 1:nargin
  printf (" %s", arg_list{i});
endfor
printf ("\n");
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_clisp() {
    script="$TMPDIR"/shebang_wrap_clisp
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/clisp
  
(format t "~&~S~&" 'Arguments)
(format t "~&~S~&" *args*)
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_php() {
    script="$TMPDIR"/shebang_wrap_php
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/php
<?php
echo "Arguments";
foreach(array_slice($argv,1) as $v)
{
  echo " $v";
}
echo "\n";
?>
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_nodejs() {
    script="$TMPDIR"/shebang_wrap_nodejs
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/node

var myArgs = process.argv.slice(2);
console.log('Arguments ', myArgs);
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_lua() {
    script="$TMPDIR"/shebang_wrap_lua
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/lua

io.write "Arguments"
for a = 1, #arg do
  io.write(" ")
  io.write(arg[a])
end
print("")
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

par_shebang_wrap_csharp() {
    script="$TMPDIR"/shebang_wrap_csharp
    cat <<'EOF' > "$script"
#!/usr/local/bin/parallel --shebang-wrap -k ARGV={} /usr/bin/csharp

var argv = Environment.GetEnvironmentVariable("ARGV");
print("Arguments "+argv);
EOF
    chmod 755 "$script"
    "$script" arg1 arg2 "arg3.1  arg3.2"
    rm "$script"
}

export -f $(compgen -A function | grep par_)
# Tested with -j1..8
# -j6 was fastest
#compgen -A function | grep par_ | sort | parallel -j$P --tag -k '{} 2>&1'
compgen -A function | grep par_ | LC_ALL=C sort | parallel -j6 --tag -k '{} 2>&1'
rmdir "$TMPDIR" "$tmp"
