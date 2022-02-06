tool
extends MarginContainer

const INTENDATION_SIZE := 25

onready var _checklist = $TabContainer/Checklist/cont/Scroll/list
onready var _changelog := $TabContainer/Changelog/edit
onready var _list_chooser := $TabContainer/Checklist/cont/btns/OptionButton
onready var _list_edit := $TabContainer/Checklist/cont/ListEdit

var plugin : EditorPlugin
var settings : Dictionary
var fh

var checklist_file_list := {}
var current_path := ""

func _ready():
	if Engine.editor_hint: return
	fh = preload("res://addons/Checklist/filehelper.gd").new()
	setup()


func setup():
	load_changelog()
	
	for folder in settings.get("checklist_locations", ["res://addons/Checklist/checklists/"]):
		for path in fh.get_files_in_directory(folder, true, "*.txt"):
			var file : String = path.get_file()
			if !checklist_file_list.keys().has(file):
				checklist_file_list[file] = path
	
	var popup : PopupMenu = _list_chooser.get_popup()
	for key in checklist_file_list.keys():
		popup.add_item(key)
	
	if checklist_file_list.size() > 0:
		_list_chooser.select(0)
		load_checklist(0)
	else:
		$TabContainer/Checklist/cont/btns/Editbtn.disabled = true


func load_checklist(id:int):
	current_path = checklist_file_list.values()[id]
	delete_checklist()
	make_checklist(fh.read_text(current_path).split("\n", false))


func make_checklist(list:Array):
	var intendation := 0
	for item in list:
		var cont := ItemContainer.new()
		if item.find("/")==-1:
			var check = CheckBox.new()
			check.text = item
			cont.add_child(check)
		
		var dat = item.strip_edges().split("/")
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
				var btn := Button.new()
				var check := CheckBox.new()
				cont.add_child(check)
				btn.text = dat[1]
				btn.connect("pressed", plugin, "execute_makro", [""])
				btn.connect("pressed", check, "set", ["pressed", true])
				cont.add_child(btn)
			"E":
				var btn = Button.new()
				var check := CheckBox.new()
				cont.add_child(check)
				btn.text = dat[1]
				btn.connect("pressed", plugin, "export_game", [false])
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

func load_changelog():
	var text = fh.read_text(settings.get("changelog_path", ""))
	if text == "": return
	
	_changelog.text = text
	
	#move cursor to the end
	var lc :int = _changelog.get_line_count()
	while lc > 0 and _changelog.get_line(lc-1).strip_edges().empty():
		lc-=1
	_changelog.cursor_set_line(lc)
	_changelog.cursor_set_column(_changelog.get_line(lc-1).length())
	
	_changelog.fold_all_lines()

func save_changelog():
	# Don't save if the changelog is empty
	if _changelog.text.strip_edges().empty(): return
	fh.write_text(settings.get("changelog_path", ""), _changelog.text)
	$AnimationPlayer.play("fade away")
	##print("saved changelog")


func _on_OptionButton_item_selected(index):
	load_checklist(index)


func _on_Editbtn_toggled(button_pressed):
	_checklist.get_parent().visible = !button_pressed
	_list_edit.visible = button_pressed
	if button_pressed:
		_list_edit.text = fh.read_text(current_path)
	else:
		if _list_edit.text.strip_edges().empty(): return
		fh.write_text(current_path, _list_edit.text)
		load_checklist(_list_chooser.selected)
	
	_list_chooser.disabled = button_pressed



class ItemContainer extends HBoxContainer:
	
	func _init():
		add_child(Control.new())
	
	func set_intendation(lenght:int):
		get_child(0).rect_min_size.x = lenght




