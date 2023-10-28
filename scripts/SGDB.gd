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
	return db_path+db_table_use+id+".sgdb.json"

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
func insert(data:Dictionary):
	for key in data.keys():
		pass

#插入一行数据
func insert_row(id,data:Dictionary):
	var path = row_path(id)
	if path == null: return
	if id_exist(id) : return
	manager.save(path,data)
	manager.replace_index(table_path(db_table_use),id,data)

#
func replace_row(id,data:Dictionary):
	var path = row_path(id)
	if path == null: return
	manager.save(path,data)
	manager.replace_index(table_path(db_table_use),id,data)

###########################
# 删除操作
#
###########################
#删除一个表
func delete_table(table):
	manager.remove(table_path(table))
	if table == db_table_use:
		db_table_use = ""

#删
func delete():
	pass

#删除一行数据
func delete_row(id):
	if check_table(): return
	manager.delete_index_row(table_path(db_table_use),id)
	manager.remove(row_path(id))

###########################
# 修改操作
#
###########################
#改
func update():
	pass

#更新一行数据
func update_row_set(id,column,value):
	if check_table(): return
	manager.update_row_set(table_path(db_table_use),id,column,value)

###########################
# 查询操作
#
###########################
func select():
	pass

#查询附带条件
func select_where(column,where):
	if check_table(): return
	return manager.select_where(table_path(db_table_use),column,where)

#查询高于一个数值
func select_where_high(column,where):
	if check_table(): return
	return manager.select_where_high(table_path(db_table_use),column,where)

#查询低于一个数值
func select_where_low(column,where):
	if check_table(): return
	return manager.select_where_low(table_path(db_table_use),column,where)

func select_blur(column,blur):
	if check_table(): return
	return manager.select_blur(table_path(db_table_use),column,blur)

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
func show_tables():
	if db_path == "":return
	return manager.get_dirs(db_path)

###########################
# 管理类
# 
###########################
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
	
	#删除文件夹
	func remove(path):
		var io_call = Callable(io,"remove")
		io_call = io_call.bind(path)
		threads.save(io_call)
	
	#删除一行索引
	func delete_index_row(path,id):
		var io_call = Callable(io,"delete_index_row")
		io_call = io_call.bind(path,id)
		threads.save(io_call)
	
	#存储和更新索引
	func replace_index(path,id,data):
		var io_call = Callable(io,"replace_index")
		io_call = io_call.bind(path,id,data)
		threads.save(io_call)
	
	func update_row_set(path,id,column,value):
		var io_call = Callable(io,"update_row_set")
		io_call = io_call.bind(path,id,column,value)
		threads.save(io_call)
	
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
	
	#查询高于
	func select_where(path,column,where):
		var io_call = Callable(io,"select_where")
		io_call = io_call.bind(path,column,where)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
		
	#查询低于
	func select_where_high(path,column,where):
		var io_call = Callable(io,"select_where_high")
		io_call = io_call.bind(path,column,where)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
	
	#带条件查询
	func select_where_low(path,column,where):
		var io_call = Callable(io,"select_where_low")
		io_call = io_call.bind(path,column,where)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
	
	#模糊查询
	func select_blur(path,column,blur):
		var io_call = Callable(io,"select_blur")
		io_call = io_call.bind(path,column,blur)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
	
	#获取全部文件夹
	func get_dirs(path):
		var io_call = Callable(io,"get_dirs")
		io_call = io_call.bind(path)
		var thread = threads.read(io_call)
		return thread.wait_to_finish()
	
###########################
# 文件流
###########################
class SGDB_IO:
	###########################
	# 索引操作
	###########################
	func create_index():
		pass
	
	func delete_index():
		pass
	
	func update_index():
		pass
	
	func select_index():
		pass
	
	#获取整个索引,如果存在的话
	func get_index(path,i_name):
		var i_path = index_path(path,i_name)
		if FileAccess.file_exists(i_path):
			var file = FileAccess.open(i_path,FileAccess.READ)
			return JSON.parse_string(file.get_as_text())
		else:
			return null
	
	###########################
	# 数据操作
	###########################
	func create_data(path,id):
		pass
	
	func delete_data(path,id):
		pass
	
	func update_data(path,id):
		pass
	
	func get_data(path,id):
		var r_path  = path+id+".sgdb.json"
		var f = FileAccess.open(r_path,FileAccess.READ)
		return f.get_as_text()
	
	func get_data_json(path,id):
		return JSON.parse_string(get_data(path,id))
	
	############################################
	# 文件/文件夹操作
	############################################
		#创建文件夹
	func mkdir(path): 
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path(path))
	
	#删除文件或文件夹
	func remove(path):
		if FileAccess.file_exists(path) : 
			DirAccess.remove_absolute(path)
			return
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
	
	#文件夹是否存在
	func exist_dir(path):
		return DirAccess.dir_exists_absolute(path)
	
	#文件是否存在
	func exist_file(path):
		return FileAccess.file_exists(path)
	
	############################################
	# 工具方法
	############################################
	func index_path(path,column):
		return path+column+".sgdb.index"
	
	func ids_to_result(path,ids):
		var result = []
		for id in ids:
			result.append(get_data(path,id))
		return result
	
	############################################
	# 模糊查询操作
	############################################
	func _select_blur_po(blur:String)->int:
		if !blur.contains("%"):
			return -1
		
		#获取长度及通配符位置
		var index     = blur.find("%")
		var blur_len  = len(blur)-1
		
		#获取通配符的位置
		if  index == 0:         #通配符在行尾
			return 2
		elif index == blur_len: #通配符在行首
			return 0
		else:                   #通配符在行中
			return 1
	
	#查询从行首的位置
	func _select_blur_with_begin(path,blur,keys,value):
		if len(keys) != len(value): return null
		var ids = []
		for i in range(len(value)):
			var val = value[i]
			if val.begins_with(blur):
				ids.append(keys[i])
		return ids_to_result(path,ids)
	
	#
	func _select_blur_with_end(path,blur,keys,value):
		if len(keys) != len(value): return null
		var ids = []
		for i in range(len(value)):
			var val = str(value[i])
			var key = keys[i]
			
			if end_with(val,blur):
				ids.append(key)
				
			#if val.end_with(blur):
			#	ids.append(key)
		return ids_to_result(path,ids)
	
	func end_with(text:String,value:String)->bool:
		return text.substr(len(text)-len(value)) == value
	
	#查询
	func _select_blur_with_center(path,blurs,keys,value):
		if len(keys) != len(value): return null
		var ids = []
		for i in range(len(value)):
			var val = value[i]
			if val.start_with(blurs[0]) && val.end_with(blurs[1]):
				ids.append(keys[i])
		return ids_to_result(path,ids)
		
	#模糊查询id
	func select_blur_id(path,blur:String):
		pass
	
	#模糊查询列
	func select_blur(path,column,blur:String):
		var index = get_index(path,column)
		var ind_k = index.keys()
		var ind_v = index.values()
		match  _select_blur_po(blur):
			-1: return ""
			0 : return _select_blur_with_begin(path,blur.trim_suffix("%"),ind_k,ind_v)
			1 : return _select_blur_with_center(path,blur.split("%"),ind_k,ind_v)
			2 : return _select_blur_with_end(path,blur.trim_prefix("%"),ind_k,ind_v)
	
	#综合性搜索
	func select(id): 
		id = str(id)
		if id.contains("%"):
			pass
		pass
	
	#查询高于
	func select_where_high(path,column,where):
		var i_path  = path+column+".sgdb.index"
		var file = FileAccess.open(i_path,FileAccess.READ)
		var json    = JSON.parse_string(file.get_as_text())
		var ids     = []
		var result  = []
		for key in json.keys():
			if int(json[key]) > int(where):
				ids.append(key)
		for id in ids:
			var r_path  = path+id+".sgdb.json"
			var f = FileAccess.open(r_path,FileAccess.READ)
			result.append(f.get_as_text())
		return result
	
	#查询低于
	func select_where_low(path,column,where):
		var i_path  = path+column+".sgdb.index"
		var file = FileAccess.open(i_path,FileAccess.READ)
		var json    = JSON.parse_string(file.get_as_text())
		var ids     = []
		var result  = []
		for key in json.keys():
			if int(json[key]) < int(where):
				ids.append(key)
		for id in ids:
			var r_path  = path+id+".sgdb.json"
			var f = FileAccess.open(r_path,FileAccess.READ)
			result.append(f.get_as_text())
		return result
	
	#带条件的查询
	func select_where(path,column,where):
		var i_path  = path+column+".sgdb.index"
		var file = FileAccess.open(i_path,FileAccess.READ)
		var json    = JSON.parse_string(file.get_as_text())
		var ids     = []
		var result  = []
		for key in json.keys():
			if json[key] == where:
				ids.append(key)
		for id in ids:
			var r_path  = path+id+".sgdb.json"
			var f = FileAccess.open(r_path,FileAccess.READ)
			result.append(f.get_as_text())
		return result
	
	
	
	#更新一行数据
	func update_row_set(path,id,column,value):
		#更新一行数据
		var i_path   = path+column+".sgdb.index"
		var file     = FileAccess.open(i_path,FileAccess.READ)
		var json     = JSON.parse_string(file.get_as_text())
		json[id]     = value
		file         = FileAccess.open(i_path,FileAccess.WRITE)
		file.store_string(JSON.stringify(json))
		
		#更新一行数据
		var r_path   = path+id+".sgdb.json"
		file         = FileAccess.open(r_path,FileAccess.READ)
		json         = JSON.parse_string(file.get_as_text())
		json[column] = value
		file         = FileAccess.open(r_path,FileAccess.WRITE)
		file.store_string(JSON.stringify(json))
		
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
	
	#创建和更新索引
	func replace_index(path,id,data):
		for key in data.keys():
			var i_path = path+key+".sgdb.index"
			if !FileAccess.file_exists(i_path):
				var f = FileAccess.open(i_path,FileAccess.WRITE)
				f.store_string("{}")
			var file = FileAccess.open(i_path,FileAccess.READ_WRITE)
			var json = JSON.parse_string(file.get_as_text())
			json[id] = data[key]
			file.store_string(JSON.stringify(json))
	
	#删除表一行的索引
	func delete_index_row(path,id):
		var f = FileAccess.open(path+id+".sgdb.json",FileAccess.READ)
		var data = JSON.parse_string(f.get_as_text())
		for key in data.keys():
			var i_path = path+key+".sgdb.index"
			if !FileAccess.file_exists(i_path):
				return
			var file = FileAccess.open(i_path,FileAccess.READ)
			var json = JSON.parse_string(file.get_as_text())
			json.erase(id)
			var content = JSON.stringify(json)
			file =  FileAccess.open(i_path,FileAccess.WRITE)
			file.store_string(content)

###########################
# 多线程管理
# Multithread management
###########################
class SGDB_Thread:

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
