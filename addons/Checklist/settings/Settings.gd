tool
extends VBoxContainer

onready var dock := $"../.."
onready var changelog_btn := $changelogbutton
var plugin : EditorPlugin


func show():
	.show()
	plugin = $"../..".plugin
	$bottompanel.set_pressed_no_signal(plugin.settings.get("use_bottom_panel"))
	$ChecklistLocations.refresh()
	changelog_btn.text = "Changelog path: " + plugin.settings["changelog_path"]
	$Filechangelog.current_file = plugin.settings["changelog_path"]


func _on_bottompanel_toggled(button_pressed):
	plugin.settings["use_bottom_panel"] = button_pressed
	plugin.update_doc_position()


func _open_search_folders_file_dialoge():
	$FileDialog.popup_centered(OS.window_size*Vector2(.7, .8))


func _on_newListFolder_item_selected(index):
	plugin.settings["checklist_folder"] = $checklistFolder/newListFolder.text


func _on_changelogbutton_pressed():
	$Filechangelog.popup_centered(OS.window_size*Vector2(.7, .8))


func _on_Filechangelog_file_selected(path : String):
	plugin.settings["changelog_path"] = path
	changelog_btn.text = "Changelog path: " + path
