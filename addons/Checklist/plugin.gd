tool
extends EditorPlugin


const DocScene = preload("res://addons/Checklist/Doc.tscn")
var exporter = preload("res://addons/Checklist/exporter.gd")

var Doc : MarginContainer
var file_helper := preload("res://addons/Checklist/filehelper.gd").new()


const default_settings := {
	"checklist_folder" : "res://addons/Checklist/checklists/",
	"use_bottom_panel" : false,
	"checklist_locations" : ["res://addons/Checklist/checklists/"],
	"template_path" : "res://addons/Checklist/Template.txt",
	"changelog_path" : "res://Changelog.txt",
}
var settings := default_settings
var threads := {}


func _enter_tree():
	var cmd_args := Array(OS.get_cmdline_args())
	if (cmd_args.has("--export") or cmd_args.has("--export-debug") or
	cmd_args.has("--no-window")):
		return
	if !Engine.editor_hint: return
	
	# load settings and use defaults if something went wrong
	var loaded_settings = file_helper.read_json("res://addons/Checklist/settings.json")
	if !loaded_settings is Dictionary: loaded_settings = default_settings
	# 
	for key in loaded_settings.keys():
		settings[key] = loaded_settings[key]
	
	add_child(file_helper)
	Doc = DocScene.instance()
	Doc.plugin = self
	Doc.settings = settings
	Doc.fh = file_helper
	update_doc_position()
	
	print("Checklist started")


func _exit_tree():
	Doc.save_changelog()
	
	remove_control_from_bottom_panel(Doc)
	remove_control_from_docks(Doc)
	Doc.queue_free()
	print("Checklist stopped ")


func _process(_delta):
	for preset in threads.keys():
		if !threads[preset].is_alive():
			threads[preset].wait_to_finish()
			threads.erase(preset)
			print(str(threads.size(), " exports still running"))


func apply_changes():
	Doc.save_changelog()
	file_helper.write_json("res://addons/Checklist/settings.json", settings)


func make_visible(visible):
	Doc.visible = visible


func execute_macro(path:String, function:="_run", args:=[]):
	if !file_helper.path_exists(path):
		push_error("Makro file (%s) doesn't exist" % path)
		return
	var obj : Object = load(path).new()
	obj.callv(function, args)


func export_game(debug:=false, presets=[]):
	for preset in presets:
		if preset == "all":
			var conf := ConfigFile.new()
			conf.load("res://export_presets.cfg")
			for section in conf.get_sections():
				if section.count(".") == 1:
					export_game(debug, [conf.get_value(section, "name")])
			return
		var thread := Thread.new()
		thread.start(exporter.new(), "threaded_export", [preset, debug])
		threads[preset] = thread


func update_doc_position():
	if settings.get("use_bottom_panel", false):
		if Doc.is_inside_tree():
			remove_control_from_docks(Doc)
		add_control_to_bottom_panel(Doc, "Checklist")
		Doc.hide()
	else:
		if Doc.is_inside_tree():
			remove_control_from_bottom_panel(Doc)
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, Doc)
