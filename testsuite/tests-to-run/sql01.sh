#!/bin/bash

exec 2>&1

## Setup
# mysqlrootpass=${mysqlrootpass:-M-b+Ydjq4ejT4E}
# MYSQL_ADMIN_DBURL=mysql://root:$mysqlrootpass@/mysql
# sql $MYSQL_ADMIN_DBURL "drop user 'sqlunittest'@'localhost'"
# sql $MYSQL_ADMIN_DBURL DROP DATABASE sqlunittest;
# sql $MYSQL_ADMIN_DBURL CREATE DATABASE sqlunittest;
# sql $MYSQL_ADMIN_DBURL "CREATE USER 'sqlunittest'@'localhost' IDENTIFIED BY 'CB5A1FFFA5A';"
# sql $MYSQL_ADMIN_DBURL "GRANT ALL PRIVILEGES ON sqlunittest.* TO 'sqlunittest'@'localhost';"

MYSQL_TEST_DBURL=mysql://tange:tange@/

echo '### Test of #! -Y with file as input'
cat >/tmp/shebang <<EOF
#!/usr/local/bin/sql -Y $MYSQL_TEST_DBURL

SELECT 'Yes it does' AS 'Testing if -Y works';
EOF
chmod 755 /tmp/shebang
/tmp/shebang

echo '### Test of #! --shebang with file as input'
cat >/tmp/shebang <<EOF
#!/usr/local/bin/sql --shebang $MYSQL_TEST_DBURL

SELECT 'Yes it does' AS 'Testing if --shebang works';
EOF
chmod 755 /tmp/shebang
/tmp/shebang

echo '### Test reading sql on command line'
sql $MYSQL_TEST_DBURL "SELECT 'Yes it does' as 'Test reading SQL from command line';"

echo '### Test reading sql from file'
cat >/tmp/unittest.sql <<EOF
DROP TABLE IF EXISTS unittest;
CREATE TABLE unittest (
          id INT,
          data VARCHAR(100)
        );
INSERT INTO unittest VALUES (1,'abc');
INSERT INTO unittest VALUES (3,'def');
SELECT 'Yes it does' as 'Test reading SQL from file works';
EOF
sql $MYSQL_TEST_DBURL/sqlunittest </tmp/unittest.sql

echo '### Test dburl with username password host port'
sql mysql://tange:tange@localhost:3306/tange </tmp/unittest.sql

echo "### Test .sql/aliases"
mkdir -p ~/.sql
echo :sqlunittest mysql://sqlunittest:CB5A1FFFA5A@localhost:3306/sqlunittest >> ~/.sql/aliases
perl -i -ne '$seen{$_}++ || print' ~/.sql/aliases
sql :sqlunittest "SELECT 'Yes it does' as 'Test if .sql/aliases works';"

echo "### Test sql:sql::alias"
sql sql:sql::sqlunittest "SELECT 'Yes it works' as 'Test sql:sql::alias';"

echo "### Test --noheaders --no-headers -n"
sql -n :sqlunittest 'select * from unittest order by id' \
| parallel -k --colsep '\t' echo {2} {1}
sql --noheaders :sqlunittest 'select * from unittest order by id' \
| parallel -k --colsep '\t' echo {2} {1}
sql --no-headers :sqlunittest 'select * from unittest order by id' \
| parallel -k --colsep '\t' echo {2} {1}

echo "### Test --sep -s";
sql --no-headers -s : pg:/// 'select 1,2' | parallel --colsep ':' echo {2} {1}
sql --no-headers --sep : pg:/// 'select 1,2' | parallel --colsep ':' echo {2} {1}

echo "### Test --passthrough -p";
sql -p -H :sqlunittest 'select * from unittest'
echo
sql --passthrough -H :sqlunittest 'select * from unittest'
echo

echo "### Test --html";
sql --html $MYSQL_TEST_DBURL/sqlunittest 'select * from unittest'
echo

echo "### Test --show-processlist|proclist|listproc";
sql --show-processlist :sqlunittest | wc -lw
sql --proclist :sqlunittest | wc -lw
sql --listproc :sqlunittest | wc -lw

echo "### Test --db-size --dbsize";
sql --dbsize :sqlunittest | wc -w
sql --db-size :sqlunittest | wc -w

echo "### Test --table-size --tablesize"
sql --showtables :sqlunittest | grep TBL | parallel sql :sqlunittest drop table
sql --tablesize :sqlunittest | wc -l
sql --table-size :sqlunittest | wc -l

echo "### Test --debug"
sql --debug :sqlunittest "SELECT 'Yes it does' as 'Test if --debug works';"

echo "### Test --version -V"
sql --version | wc
sql -V | wc

echo "### Test -r"
stdout sql -r --debug pg://nongood@127.0.0.3:2227/ "SELECT 'This should fail 3 times';"

echo "### Test --retries=s"
stdout sql --retries=4 --debug pg://nongood@127.0.0.3:2227/ "SELECT 'This should fail 4 times';"

echo "### Test --help -h"
sql --help
sql -h
