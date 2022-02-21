tool
extends VBoxContainer

onready var dock := $"../.."
var plugin : EditorPlugin


func show():
	.show()
	plugin = $"../..".plugin
	$bottompanel.set_pressed_no_signal(plugin.settings.get("use_bottom_panel"))
	$ChecklistLocations.refresh()
	


func _on_bottompanel_toggled(button_pressed):
	plugin.settings["use_bottom_panel"] = button_pressed
	plugin.update_doc_position()


func _open_search_folders_file_dialoge():
	$FileDialog.popup_centered(OS.window_size*Vector2(.7, .8))


func _on_newListFolder_item_selected(index):
	plugin.settings["checklist_folder"] = $checklistFolder/newListFolder.text
