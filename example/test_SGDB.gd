extends Node

func _ready():
	var db_path = "res://example/db/"
	var table   = "test"
	var id      = "TESTID1001"
	
	#初始化数据库并设置数据库位置
	var db = SGDB.new(db_path)
	#也可以先new在设置数据库位置
	#var db = SGDB.new()
	#db.set_path("res://example/db/")
	
	#创建一个表
	if !db.table_exist(table):
		db.create_table_use(table)
	else :
		db.use(table)
	
	#插入数据
	if !db.id_exist(id):
		db.insert_row(id,{"name":"Song","Age":"19"})
	
	#查询数据
	await  get_tree().create_timer(0.0001).timeout
	var result = db.select_row(id)
	print(result)
	
	#删除表格
	db.delete_table(table)
