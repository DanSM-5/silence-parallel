#!/bin/bash

# SPDX-FileCopyrightText: 2021-2023 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

pwd=$(pwd)
# If not run in dir parallel/testsuite: set testsuitedir to path of testsuite
testsuitedir=${testsuitedir:-$pwd}
rm -rf tmp 2>/dev/null
(
    cd "$testsuitedir"/input-files
    tar xjf random_dirs_no_newline.tar.bz2
)
cp -a "$testsuitedir"/input-files/random_dirs_no_newline tmp
cd tmp

echo '### Tests if special dir names causes problems'
ls | parallel -v touch -- {}/abc-{}-{} 2>&1 | perl -e 'print sort (<>)' | md5sum
echo -n 'There are '
find . -type d -print0 | perl -0 -ne '$a++;END{print $a}'
echo -n ' dirs with '
find . -type f -print0 | perl -0 -ne '$a++;END{print $a}'
echo ' files'
echo 'Removing files'
ls | parallel -v rm -- {}/abc-{}-{} 2>&1 | perl -e 'print sort (<>)' | md5sum
echo -n 'There are '
find . -type d -print0 | perl -0 -ne '$a++;END{print $a}'
echo -n ' dirs with '
find . -type f -print0 | perl -0 -ne '$a++;END{print $a}'
echo ' files'
echo 'Removing dirs'
ls | parallel -v rmdir -- {} 2>&1 | perl -e 'print sort (<>)' | md5sum
echo -n 'There are '
find . -type d -print0 | perl -0 -ne '$a++;END{print $a}'
echo -n ' dirs with '
find . -type f -print0 | perl -0 -ne '$a++;END{print $a}'
echo ' files'
echo '### Tests name ending in \n causes problems'
echo newline1 >'newline1
'
echo newline2 >'newline2
'
find newli* -print0 | parallel -0 cat {} ">" {}.bak
find newli* -print0 | sort -z

cd ..
rm -rf tmp
