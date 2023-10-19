extends Node

func _ready():
	#初始化数据库并设置数据库位置
	var db = SGDB.new("res://example/db/")
	#也可以先new在设置数据库位置
	#var db = SGDB.new()
	#db.set_path("res://example/db/")
	
	#创建一个表
	db.create_table_use("test")
	
	#插入数据
	db.insert("TESTID1001",{"name":"Song","Age":"19"})
	
	#查询数据
	var result = db.select_row("TESTID1001")
	print(result)
