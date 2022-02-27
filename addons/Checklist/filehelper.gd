extends Node

# This is copied from my other addon EasyFiles v1.0

var _dir := Directory.new() setget _not_setter # protected var
var _test_file := File.new() setget _not_setter # protected var


func _not_setter(__):
	pass


## general Folder operations
############################
func copy_file(from:String, to:String)->int:
	return _dir.copy(from, to)

func delete_file(path:String)->int:
	return _dir.remove(path)

func create_folder(path:String)->int:
	return _dir.make_dir_recursive(path)

func rename(from: String, to: String)->int:
	return _dir.rename(from, to)

func path_exists(path:String)->bool:
	if path.match("*.*"):
		return _dir.file_exists(path)
	return _dir.dir_exists(path)
###########################################


## json
#######
func read_json(path:String, key:="", compression=-1):
	return parse_json(read_text(path, key, compression))

func write_json(path:String, data, key:="", compression=-1)->int:
	return write_text(path, to_json(data), key, compression)
###########################################

## text
#######
func read_text(path:String, key:="", compression=-1)->String:
	var data := ""
	var err : int
	err = _open_read(path, key, compression)
	
	if err==OK:
		data = _test_file.get_as_text()
	else:
		push_error(str("Couldn't read ", path, " ErrorCode: ", err))
	
	_test_file.close()
	return data


func write_text(path:String, text:String, key:="", compression=-1)->int:
	var err : int
	err = _open_write(path, key, compression)
	
	if err==OK:
		_test_file.store_string(text)
	else:
		push_error(str("Couldn't write ", path, " ErrorCode: ", err))
	
	_test_file.close()
	return err
###########################################


## file search
##############
func get_files_in_directory(path:String, recursive=false, filter:="*"):
	var found = []
	var dirs = []
	if !path.ends_with("/"): path += "/"
	
	var dir := Directory.new()
	if dir.open(path) == OK:
		# warning-ignore:return_value_discarded
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				dirs.push_back(file_name)
			else:
				if file_name.match(filter):
					found.push_back(path+file_name)
			file_name = dir.get_next()
	else:
		return []
	
	if !recursive: return found
	
	#check other dirs if recursive
	for new_dir in dirs:
		for file in get_files_in_directory(path+new_dir+"/", true, filter):
			found.push_back(file)
	
	return found
###########################################

## Helper Functions
###################
func _open_read(path:String, key="", compression=-1)->int:
	if _test_file.is_open(): return ERR_BUSY
	if key != "":
		return _test_file.open_encrypted_with_pass(path, _test_file.READ, key)
	elif compression != -1:
		if compression < 0 or compression > 3: return ERR_INVALID_PARAMETER
		return _test_file.open_compressed(path, _test_file.READ, compression)
	else:
		return _test_file.open(path, _test_file.READ)


func _open_write(path:String, key="", compression=-1)->int:
	if _test_file.is_open(): return ERR_BUSY
	if key != "":
		return _test_file.open_encrypted_with_pass(path, _test_file.WRITE, key)
	elif compression != -1:
		if compression < 0 or compression > 3: return ERR_INVALID_PARAMETER
		return _test_file.open_compressed(path, _test_file.WRITE, compression)
	else:
		return _test_file.open(path, _test_file.WRITE)
###########################################

