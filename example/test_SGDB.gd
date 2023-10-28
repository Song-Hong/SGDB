extends Node

func _ready():
	var db_path = "res://example/db/"
	var table   = "test"
	
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
	
	#显示全部表格
	#print(db.show_tables())
	
	db.insert_row("TESTID1001",{"name":"HS","Age":"22"})
	db.insert_row("TESTID1002",{"name":"YK","Age":"22"})
	db.insert_row("TESTID1003",{"name":"XJ","Age":"22"})
	db.insert_row("TESTID1004",{"name":"WHM","Age":"3"})
	db.insert_row("TESTID1005",{"name":"HSH","Age":"4"})
	db.insert_row("TESTID1006",{"name":"HHT","Age":"5"})
	db.insert_row("TESTID1007",{"name":"PWH","Age":"6"})
	
	#按条件查询
	#await get_tree().create_timer(0.0001).timeout
	#var result = db.select_where_high("Age","21")
	#for res in result:
	#	var json = JSON.parse_string(res)
	#	print(json["name"])        
	
	await get_tree().create_timer(0.001).timeout
	var result = db.select_blur("name","%H")
	for res in result:
		var json = JSON.parse_string(res)
		print(json["name"])
	
	#通过id进行数据的查询
	#result   = db.select_row("TESTID1005")
	#print(JSON.parse_string(result))
	
	#更新数据
	#db.update_row_set("TESTID1005","Age","5")
	
	#await get_tree().create_timer(0.0001).timeout
	#result   = db.select_row("TESTID1005")
	#print(JSON.parse_string(result))
	
	#删除一行
	#db.delete_row("TESTID1004")
	#db.delete_table(table)
	
