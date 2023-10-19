extends Node

func _ready():
	#初始化数据库并设置数据库位置
	var db = SGDB.new("res://example/db/")
	#也可以先new在设置数据库位置
	#var db = SGDB.new()
	#db.db_path = "res://example/db/"
