#!/bin/bash

# Functions

ok() {
Green='\033[0;32m' #Green Color
NC='\033[0m' # No Color
echo -e "${Green}Info:${NC}$1" ;} # Green

EXPECTED_ARGS=3
E_BADARGS=65
MYSQL=`which mysql`


Q1="CREATE DATABASE IF NOT EXISTS $1;"
Q2="GRANT ALL ON *.* TO '$2'@'localhost' IDENTIFIED BY '$3';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $0 dbname dbuser dbpass"
  exit $E_BADARGS
fi

$MYSQL -uroot -e "$SQL"
ok "Database $1 and user $2 created with a password $3"
#Dropping tables if they already exist
Q1="DROP TABLE IF EXISTS $1.user;"
SQL="${Q1}"
$MYSQL -e "$SQL"
Q1="DROP TABLE IF EXISTS $1.UserGroupTable;"
SQL="${Q1}"
$MYSQL -e "$SQL"
Q1="DROP TABLE IF EXISTS $1.GroupTable;"
SQL="${Q1}"
$MYSQL -e "$SQL"

#Create user table
Q1="CREATE TABLE IF NOT EXISTS user (Id bigint NOT NULL,"
Q2="name varchar(20), GId bigint, PRIMARY KEY (Id));"
DSQL="${Q1}${Q2}"
$MYSQL -D$1 -e "$DSQL"
ok "user table created"

#Create group table
Q1="CREATE TABLE IF NOT EXISTS GroupTable (Id bigint NOT NULL,"
Q2="name varchar(20), PRIMARY KEY (Id));"
DSQL="${Q1}${Q2}"
$MYSQL -D$1 -e "$DSQL"
ok "group table created"

#Create user-group mapping table
Q1="CREATE TABLE IF NOT EXISTS UserGroupTable (GId bigint NOT NULL, "
Q2="UG_UId bigint NOT NULL, CONSTRAINT FK_GroupId FOREIGN KEY(GId) "
Q3="REFERENCES GroupTable(Id) ON DELETE CASCADE ON UPDATE CASCADE);"
DSQL="${Q1}${Q2}${Q3}"
$MYSQL -D$1 -e "$DSQL"
ok "user-group table created"

#Populate user table
# LOAD DATA INFILE is faster than INSERT STATEMENTS
#Security hole: find another way
# Note: Add absolute path of testuser.txt file in userspathplaceholder in line 65
Q1="LOAD DATA LOCAL INFILE [userspathplaceholder] INTO TABLE"
Q2=" user COLUMNS TERMINATED BY ':';"
DSQL="${Q1}${Q2}"
$MYSQL --local-infile -D$1 -e "$DSQL"
ok "user table populated"

#Populate group table
# Note: Add absolute path of testgroup.txt file in groupspathplaceholder in line 73
Q1="LOAD DATA LOCAL INFILE [groupspathplaceholder]"
Q2=" INTO TABLE GroupTable FIELDS TERMINATED BY ':';"
DSQL="${Q1}${Q2}"
$MYSQL --local-infile -D$1 -e "$DSQL"
ok "group table populated"

#Populate user-group mapping table
#Store necessary fields i.e. $1 and comma separated values in $3 converted to
#rows in a separate file
# Note: Add absolute path of testusergroup.txt file in usergroupspathplaceholder in line 84
awk  '{if(match($3,/^([1-9][0-9]*,)+[1-9][0-9]*$/)) {split($3,a,","); for(i in a) print $1":"a[i];}  else print $1":"$3}' FS=":" testgroup.txt > testusergroup.txt
Q1="LOAD DATA LOCAL INFILE [usergroupspathplaceholder]"
Q2=" INTO TABLE UserGroupTable FIELDS TERMINATED BY ':';"
DSQL="${Q1}${Q2}"
$MYSQL --local-infile -D$1 -e "$DSQL"
ok "user-group table populated"

#Create index on user.id, user.gid, usergrouptable.ug_uid and usergrouptable
#.ug_gid
Q1="ALTER TABLE user ADD INDEX u_index(GId);"
DSQL="${Q1}"
$MYSQL --local-infile -D$1 -e "$DSQL"
Q2="ALTER TABLE UserGroupTable ADD INDEX ug_index(GId,UG_UId);"
DSQL="${Q2}"
$MYSQL --local-infile -D$1 -e "$DSQL"

#Fetch users with no groups : left join user and usergroup table, return rows where usergroup.ug_id was null
# Note: Add absolute path of testusergroup.txt file in resultspathplaceholder in line 104
Q1="Select nogroup.id, nogroup.name  From ( select u.id,u.name,ug.ug_uid from"
Q2=" user AS u LEFT JOIN usergrouptable AS ug ON u.id =ug.ug_uid AND u.gid=ug"
Q3=".gid) nogroup where nogroup.ug_uid IS NULL INTO OUTFILE"
Q4=" '[resultspathplaceholder]results$RANDOM.txt';"
DSQL="${Q1}${Q2}${Q3}${Q4}"
$MYSQL --local-infile -D$1 -e "$DSQL"

