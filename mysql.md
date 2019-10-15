## Ubuntu apparmor change when changing MySQL data/log directory 

when change the data/log directory
https://www.digitalocean.com/community/tutorials/how-to-move-a-mysql-data-directory-to-a-new-location-on-ubuntu-16-04 


## create user and grant permission
TL;DR
```bash
MYSQL_USER="user"
MYSQL_PASS="pass"
SOURCE_IP="xxx.xxx.xxx.xxx"
ROOT_PASS="MySQL_Root_Password" 
DB_NAME="MySQL_TARGET_DB_NAME"
mysql -uroot -p$ROOT_PASS -e "CREATE USER '"$MYSQL_USER"'@'"$SOURCE_IP"' IDENTIFIED BY '"$MYSQL_PASS"'; "
mysql -uroot -p$ROOT_PASS -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '"$MYSQL_USER"'@'"$SOURCE_IP"'; "
mysql -uroot -p$ROOT_PASS -e "FLUSH PRIVILEGES;"
```
1. create user
```sql
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';
```

2. grant permission
```sql
GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'localhost';
FLUSH PRIVILEGES;
```
More abount grant:
```sql
GRANT [type of permission] ON [database name].[table name] TO ‘[username]’@'localhost’;
```
Revoke user permission: 
```sql
REVOKE [type of permission] ON [database name].[table name] FROM ‘[username]’@‘localhost’;
```
Delete a user all permission: 
```sql
DROP USER ‘demo’@‘localhost’;
```

## additional increment id for result view
```sql
SET @s=0;
SELECT @s:=@s+1 _id, A.uid,A.username,A.groupid FROM discuz.pre_common_member AS A
WHERE A.groupid=8
ORDER BY A.uid;
```
the result is
```
'1','30','morganwu277','8'
'2','33','renkang','8'
'3','34','ihuguowei','8'
'4','36','sperictao','8'
.....
```
## move mysql data files to a new node(Ubuntu)
1. rsync files and configuration

2. AppArmor modfication:
 - comment out the `include <local/usr.sbin.mysqld>` in `/etc/apparmor.d/usr.sbin.mysqld`
 - edit `/etc/apparmor.d/local/usr.sbin.mysqld` 

   ```
   /mnt/volume-sgp1-01/mysql/ r,
   /mnt/volume-sgp1-01/mysql/** rwk,
   ```
3. reload apparmor rules
```
sudo service apparmor reload
```

## accelerate mysql load speed 
1. You can tell MySQL to not enforce foreign key and uniqueness constraints:

```mysql
  SET FOREIGN_KEY_CHECKS = 0;
  SET UNIQUE_CHECKS = 0;
```

and drop the transaction isolation guarantee to UNCOMMITTED: `SET SESSION tx_isolation='READ-UNCOMMITTED'`
and turn off the binlog with: `SET sql_log_bin = 0`
And when you’re done, don’t forget to turn it back on with:

```mysql
  SET UNIQUE_CHECKS = 1;
  SET FOREIGN_KEY_CHECKS = 1;
  SET SESSION tx_isolation='READ-REPEATABLE';
```

## Stat on the table size of a DB
```sql
SELECT 
    table_name AS `Table`, 
    round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` 
FROM information_schema.TABLES 
WHERE table_schema = "$DB_NAME"
    AND table_name = "$TABLE_NAME";
or this query to list the size of every table in every database, largest first:

SELECT 
     table_schema as `Database`, 
     table_name AS `Table`, 
     round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` 
FROM information_schema.TABLES 
ORDER BY (data_length + index_length) DESC;
```


## All kinds of join.
   Problems like how to calculate SetA-SetB question.    
   Here is all kinds of join in sql. 
   ![sql_join](sql_join.jpg)

## table storage size calculation
```sql
SELECT
  TABLE_NAME AS `Table`,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
  information_schema.TABLES
WHERE
  TABLE_SCHEMA = "bookstore" # here you have your own database name
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH)
DESC;
```
