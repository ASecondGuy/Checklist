tool
extends MarginContainer

const INTENDATION_SIZE := 25

onready var _checklist = $TabContainer/Checklist/cont/Scroll/list
onready var _changelog := $TabContainer/Changelog
onready var _list_chooser := $TabContainer/Checklist/cont/btns/OptionButton
onready var _list_edit := $TabContainer/Checklist/cont/ListEdit
onready var _name_edit := $TabContainer/Checklist/cont/btns/NameEdit
onready var _edit_btn := $TabContainer/Checklist/cont/btns/Editbtn
onready var _uncheck_btn := $TabContainer/Checklist/cont/btns/uncheckbtn

var plugin : EditorPlugin
var last_loaded_checklist := ""
var settings : Dictionary
var fh

var checklist_file_list := {}
var current_path := ""

func _enter_tree():
	if !Engine.editor_hint:
		fh = preload("res://addons/Checklist/filehelper.gd").new()

func _ready():
	call_deferred("find_checklists")

func save_changelog():
	_changelog.save_changelog()


func find_checklists():
	if !is_instance_valid(plugin): return
	settings = plugin.settings
	
	checklist_file_list.clear()
	for folder in settings.get("checklist_locations", ["res://addons/Checklist/checklists/"]):
		for path in fh.get_files_in_directory(folder, true, "*.txt"):
			var file : String = path.get_file().trim_suffix(".txt")
			if !checklist_file_list.keys().has(file):
				checklist_file_list[file] = path
	
	var current : String = _list_chooser.text
	
	var popup : PopupMenu = _list_chooser.get_popup()
	while popup.get_item_count() > 0: popup.remove_item(0)
	for key in checklist_file_list.keys():
		popup.add_item(key)
	popup.add_item("New")
	
	if checklist_file_list.size() > 0:
		var id : int = checklist_file_list.keys().find(current)
		if id == -1: id = 0
		_list_chooser.select(id)
		load_checklist(id)
		_edit_btn.disabled = false
	else:
		_edit_btn.disabled = true
		delete_checklist()
		_list_chooser.text = ""
	
	# finalize edits in case there are some
	_visual_edit_enable(false)
	_edit_btn.set_pressed_no_signal(false)
	


func load_checklist(id:int):
	if checklist_file_list.size() <= id or id < 0:
		# New file
		var new_name : String = "new_list%s"
		if checklist_file_list.has(new_name % ""):
			var i = 1
			while checklist_file_list.has(new_name % i):
				i+=1
			new_name = new_name % i
		else:
			new_name = new_name % ""
		var pop : PopupMenu = _list_chooser.get_popup()
		pop.set_item_text(id, new_name)
		pop.add_item("New")
		_list_chooser.selected = id
		_list_chooser.text = new_name
		checklist_file_list[new_name] = settings.get("checklist_folder")+new_name+".txt"
		fh.write_text(checklist_file_list[new_name], fh.read_text(settings.template_path))
	
	var next_path : String = checklist_file_list.values()[id]
	if next_path == last_loaded_checklist: return
	current_path = next_path
	last_loaded_checklist = next_path
	_name_edit.text = checklist_file_list.keys()[id]
	delete_checklist()
	make_checklist(fh.read_text(current_path).split("\n", false))



func make_checklist(list:Array):
	var intendation := 0
	var split_symbol := "|"
	for item in list:
		if item.strip_edges().begins_with("#"):
			continue
		
		var cont := ItemContainer.new()
		if item.find(split_symbol)==-1:
			var check = CheckBox.new()
			check.text = item
			cont.add_child(check)
		
		var dat : Array = item.strip_edges().split(split_symbol)
		match dat[0].strip_edges():
			"I":
				if dat[1].begins_with("="):
					intendation = int(dat[1].substr(1))
				else:
					intendation+=int(dat[1])
			"L":
				var lab = Label.new()
				lab.text = dat[1]
				cont.add_child(lab)
			"M":
				# skip if to few arguments
				if dat.size() < 3: continue
				var btn := Button.new()
				var check := CheckBox.new()
				cont.add_child(check)
				btn.text = dat[1]
				btn.connect("pressed", self, "_macro_request", [cont, dat])
				btn.connect("pressed", check, "set", ["pressed", true])
				cont.add_child(btn)
			"E":
				# skip if to few arguments
				if dat.size() < 4: continue
				var btn = Button.new()
				var check := CheckBox.new()
				cont.add_child(check)
				btn.text = dat[1]
				btn.connect("pressed", plugin, "export_game", 
				[dat[2].to_lower()=="true", dat.slice(3, dat.size()-1)])
				btn.connect("pressed", check, "set", ["pressed", true])
				cont.add_child(btn)
			"O":
				# skip if to few arguments
				if dat.size() < 2: continue
				# argument 2 is optional
				if dat.size() == 2: 
					dat.push_back(dat[1])
				var btn = Button.new()
				var check := CheckBox.new()
				cont.add_child(check)
				btn.text = dat[1]
				btn.icon = preload("res://addons/Checklist/icons/LinkButton.svg")
				var path : String = dat[2]
				if path.begins_with("res:") or path.begins_with("user:"):
					path = ProjectSettings.globalize_path(path)
				btn.connect("pressed", OS, "shell_open", [path])
				btn.connect("pressed", check, "set", ["pressed", true])
				cont.add_child(btn)
			_:
				pass
		
		
		_checklist.add_child(cont)
		cont.set_intendation(intendation*INTENDATION_SIZE)


func uncheck_checklist(parent:=_checklist):
	for child in parent.get_children():
		if child is CheckBox:
			child.pressed = false
		uncheck_checklist(child)


func delete_checklist():
	# remove everything exep the important buttons
	for child in _checklist.get_children():
		child.queue_free()


func _on_OptionButton_item_selected(index):
	load_checklist(index)


func _on_Editbtn_toggled(button_pressed):
	last_loaded_checklist = ""
	_uncheck_btn.visible = !button_pressed
	if button_pressed:
		_list_edit.text = fh.read_text(current_path)
	else:
		# change the name if needed
		var id : int = _list_chooser.selected
		if _name_edit.text != _list_chooser.text:
			var new_path : String = current_path.get_base_dir()+"/"+_name_edit.text+".txt"
#			prints(current_path, new_path, fh.path_exists(new_path))
			if !fh.path_exists(new_path):
				fh.rename(current_path, new_path)
				checklist_file_list.erase(_list_chooser.text)
				checklist_file_list[_name_edit.text] = new_path
				# move complete update values & UI
				current_path = new_path
				_list_chooser.text = _name_edit.text
				_list_chooser.get_popup().set_item_text(id, _name_edit.text)
		
		# save only if something is written nobody wants to save an empty doc
		if _list_edit.text.strip_edges().empty(): return
		fh.write_text(current_path, _list_edit.text)
	
	_visual_edit_enable(button_pressed)


func _visual_edit_enable(active:=true):
	_list_chooser.visible = !active
	_checklist.get_parent().visible = !active
	_name_edit.visible = active
	_list_edit.visible = active
	if !active:
		load_checklist(_list_chooser.selected)

func delete_current_checklist():
	fh.delete_file(current_path)
	find_checklists()


class ItemContainer extends HBoxContainer:
	
	func _init():
		add_child(Control.new())
	
	func set_intendation(lenght:int):
		get_child(0).rect_min_size.x = lenght


func _on_TabContainer_tab_changed(tab):
	if tab == 2: 
		$TabContainer/Settings.show()
	if tab != 0: return
	find_checklists()

func _macro_request(cont:ItemContainer, data:Array):
	var script_path : String = data[2]
	var function : String = "_run"
	if data.size() >= 4: function = data[3]
	
	if function.empty() or !function.is_valid_filename(): function = "_run"
	var args := []
	for i in range(2, cont.get_child_count(), 2):
		# TODO: get the values from the children in here
		pass
	
	plugin.execute_macro(script_path, function, args)
