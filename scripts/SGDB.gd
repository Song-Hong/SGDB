###########################
# 数据库
# database
###########################
extends Node
class_name SGDB

###########################
# 变量
# 
###########################
var db_path = ""            #数据库路径 database path
var db_table_use = ""       #数据库当前使用的表格
var manager:SGDB_Manager    #数据库线程 database thread

###########################
# 初始化数据
# initialize database
###########################
#初始化
func _init(path=""):
	manager = SGDB_Manager.new()
	set_path(path)
	
#设置路径
func set_path(path):
	db_path = path
	if !db_path.ends_with("/"):
		db_path+="/"

###########################
# 工具方法
# Tools func
###########################
#使用表格
func use(table):
	db_table_use = table
	if !db_table_use.ends_with("/"):
		db_table_use += "/"

#获取表格路径
func table_path(table):
	return db_path+table
	

#获取一列的数据
func row_path(id):
	if check_table(): return null
	return db_path+db_table_use+id+".json"

#检查表格是否正确
func check_table():
	var state = db_table_use == ""
	if state:
		printerr("Tables that are not currently in use")
	return state

###########################
# 插入数据
# insert data
###########################
#创建一个表
func create_table(table:String):
	manager.mkdir(db_path+table)

#创建一个表并使用
func create_table_use(table):
	create_table(table)
	use(table)

#插入数据
func insert():
	pass

#插入一行数据
func insert_row(id,data):
	var path = row_path(id)
	if path == null: return
	manager.save(path,data)

#删除一个表
func delete_table(table):
	manager.remove(table_path(table))
	if table == db_table_use:
		db_table_use = ""

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

#查询一行数据
func select_row(id):
	var path = row_path(id)
	if path == null: return
	return manager.read(path)

#查询表是否存在
func table_exist(table):
	return manager.exist_dir(table_path(table))
	
#查询id是否存在
func id_exist(id):
	var path = row_path(id)
	if path == null: return
	return manager.exist_file(path)

#显示现在全部的表格
#show now exsit tables
func show_table():
	pass

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
		io_call = io_call.bind(path)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
	
	#写操作
	func save(path,content):
		var io_call = Callable(io,"save")
		io_call = io_call.bind(path,content)
		threads.save(io_call)
	
	#创建文件夹
	func mkdir(path):
		var io_call = Callable(io,"mkdir")
		io_call = io_call.bind(path)
		threads.save(io_call)
	
	#删除文件或文件夹
	func remove(path):
		var io_call = Callable(io,"remove")
		io_call = io_call.bind(path)
		threads.save(io_call)
	
############################
#	查询操作
#
###########################
	#文件夹是否存在
	func exist_dir(path):
		var io_call = Callable(io,"exist_dir")
		io_call = io_call.bind(path)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
	
	#文件是否存在
	func exist_file(path):
		var io_call = Callable(io,"exist_file")
		io_call = io_call.bind(path)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()



###########################
# 文件流
###########################
class SGDB_IO:
	
	func _init():
		pass
	
	#读取文件的内容
	func read(path):
		var _read = FileAccess.open(path,FileAccess.READ)
		var value = _read.get_as_text()
		_read.close()
		return value
	
	#向文件写入文件流
	func save(path,content):
		var _save = FileAccess.open(path,FileAccess.WRITE)
		_save.store_string(JSON.stringify(content))
		_save.close()
	
	#创建文件夹
	func mkdir(path):
		DirAccess.make_dir_absolute(path)
	
	#删除文件或文件夹
	func remove(path):
		path = ProjectSettings.globalize_path(path)
		for file in get_all_files(path):
			DirAccess.remove_absolute(file)
		for dir in get_all_dirs(path):
			DirAccess.remove_absolute(dir)
		DirAccess.remove_absolute(path)
		
	#获取当前目录下的全部文件,包含子文件
	func get_all_files(dir_path):
		var dirs  = DirAccess.open(dir_path)
		var files = []
		if !dir_path.ends_with("/"):
			dir_path+="/"
		for dir in dirs.get_directories():
			for file in get_all_files(dir_path+dir):
				files.append(file)
		for file in dirs.get_files():
			files.append(dir_path+file)
		return files
	
	#获取全部文件夹,包含子目录文件夹
	func get_all_dirs(dir_path):
		var directory = []
		var dirs  = DirAccess.open(dir_path)
		if !dir_path.ends_with("/"):
			dir_path+="/"
		for dir in dirs.get_directories():
			var path = dir_path+dir
			for d in get_all_dirs(path):
				directory.append(d)
			directory.append(path)
		return directory
			
	#获取当前目录下的全部文件
	func get_files(path):
		return DirAccess.get_files_at(path)
	
	#获取当前目录下的全部文件夹
	func get_dirs(path):
		return DirAccess.get_directories_at(path)
	
############################
#	查询操作
#
###########################
	#文件夹是否存在
	func exist_dir(path):
		return DirAccess.dir_exists_absolute(path)
	
	#文件是否存在
	func exist_file(path):
		return FileAccess.file_exists(path)
	
#多线程管理
#Multithread management
class SGDB_Thread:

	#初始化
	func _init():
		pass
	
	#读线程
	func read(_call:Callable):
		var thread = Thread.new()
		thread.start(_call)
		return thread
	
	#写线程
	func save(_call:Callable):
		var thread = Thread.new()
		thread.start(_call,Thread.PRIORITY_HIGH)
		thread.wait_to_finish()
