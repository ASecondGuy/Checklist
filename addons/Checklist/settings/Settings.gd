tool
extends VBoxContainer

onready var dock := $"../.."
var plugin : EditorPlugin


func show():
	.show()
	plugin = $"../..".plugin
	$bottompanel.set_pressed_no_signal(plugin.settings.get("use_bottom_panel"))
	
	


func _on_bottompanel_toggled(button_pressed):
	plugin.settings["use_bottom_panel"] = button_pressed
	plugin.update_doc_position()
