all:
	perl -e 'exit $$ENV{YYYYMMDD} !~ /20/' 
	cd ../debian/ && make
	osc rm home-tange/parallel/parallel_*.dsc || true
	cp ../debian/parallel_*.dsc ../debian/parallel_*.tar.gz home-tange/parallel/
	cp `ls ../../parallel-2*.tar.bz2|grep -v latest|tail -n1` home-tange/parallel/
	cp `ls ../../parallel-2*.tar.bz2.sig|grep -v latest|tail -n1` home-tange/parallel/
	perl -i -pe '/Version:/ and s/20\d\d\d\d\d\d/$$ENV{YYYYMMDD}/g' home-tange/parallel/parallel.spec
	cd home-tange/parallel && make
