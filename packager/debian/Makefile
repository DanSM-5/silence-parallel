# SPDX-FileCopyrightText: 2021-2022 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

all:	clean makedist unpack build

unpack:
	ls ../../parallel-*.tar.bz2| tail -n1 | parallel tar xvf 
	cd parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]; cp -a ../debian-template debian

build:
	which dpkg-buildpackage >/dev/null || ( \
	echo "Error, could not find 'dpkg-buildpackage'." ; \
	echo "To install, run:" ; \
	echo -e "\tapt-get install dpkg-dev" ; \
	false )
	cd parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]; perl -i -pe "s/201[0-9]{5}-[0-9]+/"$$(src/parallel --minversion 1)"/" debian/changelog
	cd parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]; dpkg-buildpackage -us -uc -tc
	@echo 
	@echo "To install the GNU Parallel Debian package, run:"
	@echo "    sudo dpkg -i "`ls -rt parallel_*_all.deb | tail -n 1`

clean:
	rm -f parallel_*
	rm -rf parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]

distclean:
	rm -f parallel_*
	rm -rf parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]

makedist:
	cd ../..; test [ -f Makefile ] || ./configure
	cd ../..; make dist-bzip2
	cd ../..; make dist-gzip
