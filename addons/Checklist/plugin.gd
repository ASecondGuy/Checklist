tool
extends EditorPlugin


const DocScene = preload("res://addons/Checklist/Doc.tscn")

var Doc : MarginContainer
var file_helper := preload("res://addons/Checklist/filehelper.gd").new()


var settings := {
	"checklist_folder" : "res://addons/Checklist/checklists/",
	
}


func _ready():
	add_child(file_helper)
	Doc = DocScene.instance()
	Doc.plugin = self
	Doc.settings = settings
	Doc.fh = file_helper
	Doc.hide()
	add_control_to_bottom_panel(Doc, "Checklist")
	Doc.load_changelog()
	load_checklist()
	
	print("Checklist started")


func _print_with_children(node:Node, indent:=0):
	var out = "	".repeat(indent)
	if node is Button or node is Label:
		out += str(node, " ", node.text)
	else:
		out += str(node)
	print(out)
	for c in node.get_children():
		_print_with_children(c, indent+1)


func _exit_tree():
	Doc.save_changelog()
	remove_control_from_bottom_panel(Doc)
	Doc.queue_free()
	print("Checklist stopped ")


func apply_changes():
	Doc.save_changelog()


func make_visible(visible):
	Doc.visible = visible


func load_checklist():
	var f = File.new()
	if f.open("res://addons/Checklist/checklists/checklist.txt", f.READ) == OK:
		var data = f.get_as_text()
		data = data.split("\n")
		Doc.add_checklist(data)


func execute_makro(path:String, function:="run", args:=[]):
	print("ReleaseChecker does not support makros yet")

func export_game(debug:=false, presets=[]):
	pass

