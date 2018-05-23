

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

## All kinds of join.
   Problems like how to calculate SetA-SetB question.    
   Here is all kinds of join in sql. 
   ![sql_join](sql_join.jpg)

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
