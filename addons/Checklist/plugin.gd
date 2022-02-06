tool
extends EditorPlugin


const DocScene = preload("res://addons/Checklist/Doc.tscn")

var Doc : MarginContainer
var file_helper := preload("res://addons/Checklist/filehelper.gd").new()


const default_settings := {
	"checklist_folder" : "res://addons/Checklist/checklists/",
	"use_bottom_panel" : false,
	"checklist_locations" : ["res://addons/Checklist/checklists/"],
}
var settings := default_settings


func _ready():
	add_child(file_helper)
	Doc = DocScene.instance()
	Doc.plugin = self
	
	# load settings and use defaults if something went wrong
	var loaded_settings = file_helper.read_json("res://addons/Checklist/settings.json")
	if !loaded_settings is Dictionary: loaded_settings = default_settings
	# 
	for key in loaded_settings.keys():
		settings[key] = loaded_settings[key]
	
	
	Doc.settings = settings
	Doc.fh = file_helper
	if settings.get("use_bottom_panel", true):
		add_control_to_bottom_panel(Doc, "Checklist")
		Doc.hide()
	else:
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, Doc)
	Doc.setup()
	
	print("Checklist started")


func _exit_tree():
	Doc.save_changelog()
	remove_control_from_bottom_panel(Doc)
	Doc.queue_free()
	print("Checklist stopped ")


func apply_changes():
	Doc.save_changelog()
	file_helper.write_json("res://addons/Checklist/settings.json", settings)


func make_visible(visible):
	Doc.visible = visible


func execute_makro(path:String, function:="run", args:=[]):
	print("ReleaseChecker does not support makros yet")

func export_game(debug:=false, presets=[]):
	pass

