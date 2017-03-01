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
