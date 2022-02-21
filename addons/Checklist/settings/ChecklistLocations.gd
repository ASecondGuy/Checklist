tool
extends VBoxContainer

onready var add_btn := $HBoxContainer/addbtn
onready var list := $list
onready var selector := $"../checklistFolder/newListFolder"


func _on_togglebtn_toggled(button_pressed):
	$HBoxContainer/togglebtn.text = ["show", "hide"][int(button_pressed)]
	add_btn.visible = button_pressed
	list.visible = button_pressed

func refresh():
	for li in list.get_children():
		li.queue_free()
	for path in get_parent().plugin.settings.get("checklist_locations", []):
		add_list_item(path)
	call_deferred("refresh_selection")


func add_path(path:String):
	var paths : Array = get_parent().plugin.settings.get("checklist_locations")
	if paths.has(path): return
	paths.push_back(path)
	add_list_item(path)
	get_parent().plugin.settings["checklist_locations"] = paths

func add_list_item(path:String):
	var cont := HBoxContainer.new()
	var label := Label.new()
	label.text = path
	label.clip_text = true
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	cont.add_child(label)
	var btn := Button.new()
	btn.icon = preload("res://addons/Checklist/icons/Remove.svg")
	cont.add_child(btn)
	list.add_child(cont)
	btn.connect("pressed", self, "remove_path", [path, cont])

func remove_path(path:String, cont=null):
	if list.get_child_count() <= 1: return
	if is_instance_valid(cont): 
		cont.queue_free()
	var paths : Array = get_parent().plugin.settings.get("checklist_locations")
	paths.erase(path)
	get_parent().plugin.settings["checklist_locations"] = paths
	refresh_selection()


func _on_FileDialog_dir_selected(dir:String):
	if !dir.ends_with("/"):
		dir+="/"
	add_path(dir)
	refresh_selection()

func refresh_selection():
	selector.clear()
	var paths : Array = get_parent().plugin.settings.get("checklist_locations")
	selector.text = get_parent().plugin.settings.get("checklist_folder")
	for path in paths:
		selector.add_item(path)
		if path == get_parent().plugin.settings.get("checklist_folder"):
			selector.select(selector.get_item_count()-1)
	
