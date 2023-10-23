# SGDB

#### 简单的使用

##### 创建表

创建一个表

```
db.create_table("table")
```

在使用表格时需要使用

```
db.use("table")
```

或者直接使用,该方法会在创建表后,直接使用当前创建的表

```
db.create_table_use(table)
```



#### 插入数据

插入一行数据

```
db.insert_row("TESTID1001",{"name":"ZS","Age":"22"})
db.insert_row("TESTID1002",{"name":"LS","Age":"22"})
db.insert_row("TESTID1003",{"name":"WW","Age":"22"})
db.insert_row("TESTID1004",{"name":"ZS","Age":"24"})
```



#### 删除数据

删除一行数据

```
db.delete_row("TESTID1004")
```

删除一个表

```
db.delete_table("table")
```



#### 更新数据

更新一行数据

```
db.update_row_set("TESTID1004","name","HS")
```



#### 查询数据

按条件查询

```
var result = db.select_where("Age","22")
for res in result:
var json = JSON.parse_string(res)
print(json["name"])
```

按id查询

```
var result   = db.select_row("TESTID1004")
print(JSON.parse_string(result))
```

