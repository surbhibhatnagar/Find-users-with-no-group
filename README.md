# Find-users-with-no-group-bash-MySql
### Summary:
This bash script creates database and necessary tables from testuser.txt and testgroup.txt.
| File        | Line Format   | Example  |
| ------------- |:-------------:| -----:|
| testuser     | id:name:group_id | 1:surbhi:8 |
| testgroup     | id:name:user_ids      |  8:group8:1,5,7|

It then saves the users that do not belong to a group in result[0-9]\*.txt file
The 3 cases where a user is considered to not have a group are:
1. Group_id is null for a user in testuser.txt
2. Group_id is defined for a user in testgroup.txt but the Group does not exist.
3. Group_id is defined for a user in testgroup.txt but the Group does not contain the said user.

### To Run:
#### Prereq: 
1. MySQL 5.6 or above
2. MySQL server should be up and running
3. Copy the contents of my.conf to your local machine at /etc/my.conf. It contains the required database configurations.
   Update username and password of MySQL server in [client] section.
4. Restrict access permission of my.conf file to current user
   <b>sudo chmod 600 /etc/my.confg </b>
Note: This script is test on Mac OS platform, it may not work properly on other platforms.
#### To run the script:
<b>./dbscript.sh <dbname> <dbuser> <dbpwd> </b>
