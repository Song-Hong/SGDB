###########################
# 数据库
# database
###########################
extends Node
class_name SGDB

###########################
# 数据库路径
# database path
###########################
var db_path = ""

###########################
# 数据库当前使用的表格
# 
###########################
var db_table_use = ""

###########################
#数据库线程
#database thread
###########################
var manager:SGDB_Manager

###########################
# 初始化数据
# initialize database
###########################
func _init(path=""):
	manager = SGDB_Manager.new()
	db_path = path

###########################
# 插入数据
# insert data
###########################
func insert():
	pass

#插入数据_多线程
func insert_thread():
	pass

#插入一行数据
func insert_row():
	pass

#删
func delete():
	pass

#删除一行数据
func delete_row():
	pass

#改
func update():
	pass

#改一行数据
func update_row():
	pass

#查
func select():
	pass

#显示现在全部的表格
#show now exsit tables
func show_table():
	pass

#关闭数据库
func close():
	manager.close()

#管理类
class SGDB_Manager:
	
	#多线程
	var threads:SGDB_Thread
	
	#io流
	var io:SGDB_IO
	
	#初始化
	func _init():
		threads = SGDB_Thread.new()
		io      = SGDB_IO.new()
	
	#读操作
	func read(path):
		var io_call = Callable(io,"read")
		var value = io_call.call(path)
		threads.read(io_call)
		return value
	
	#写操作
	func save(path,content):
		var io_call = Callable(io,"save")
		io_call.call(path,content)
		threads.save(io_call)

###########################
# 文件流
###########################
class SGDB_IO:
	
	func _init():
		pass
	
	#读取文件的内容
	func read(path):
		var _read = FileAccess.open(path,FileAccess.READ)
		return _read.get_as_text()
		_read.close()
	
	#向文件写入文件流
	func save(path,content):
		var _save = FileAccess.open(path,FileAccess.WRITE)
		_save.store_string(content)
		_save.close()

#多线程管理
#Multithread management
class SGDB_Thread:

############################
#	读线程运行状态
#	写线程运行状态
###########################
	var read_state = false
	var save_state = false
	
############################
#	读线程队列
#	写线程队列
###########################
	var read_list = []
	var save_list = []
	
	#初始化
	func _init():
		pass
	
	#读线程
	func read(_call:Callable):
		var thread = Thread.new()
		read_list.append({_call:thread})
	
	#写线程
	func save(_call:Callable):
		var thread = Thread.new()
		read_list.append({_call:thread})
	
	#读线程
	func start_read():
		if read_state : return
		read_state = true
		while len(read_list) > 0:
			for key in read_list[0].keys():
				var thread = read_list[0][key]
				thread.start(key)
				await thread.wait_to_finish()
				read_list.remove_at(0)
		read_state = false
	
	#存储线程
	func start_save():
		if save_state : return
		save_state = true
		while len(save_list) > 0:
			for key in save_list[0].keys():
				var thread = save_list[0][key]
				thread.start(key)
				await thread.wait_to_finish()
				save_list.remove_at(0)
		save_state = false
	
	#关闭全部线程
	func close():
		read_state = true
		save_state = true
		read_list.clear()
		save_list.clear()
