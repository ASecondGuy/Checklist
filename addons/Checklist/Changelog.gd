tool
extends VBoxContainer

onready var _edit = $edit
onready var _doc = get_parent().get_parent()
onready var _anim := $AnimationPlayer

func _ready():
	_anim.play("fade away")


func load_changelog():
	var text = get_fh().read_text(get_settings().get("changelog_path", ""))
	if text == "": return
	_edit.text = text
	
	# manage folding
	_edit.fold_all_lines()
	var idx : int = _edit.get_line_count()-1
	while idx > 0:
		idx-=1
		if _edit.is_folded(idx):
			_edit.unfold_line(idx)
			break
	
	#move cursor to the end
	var lc :int = _edit.get_line_count()
	while lc > 0 and _edit.get_line(lc-1).strip_edges().empty():
		lc-=1
	_edit.cursor_set_line(lc)
	_edit.cursor_set_column(_edit.get_line(lc-1).length())
	_edit.grab_focus()

func save_changelog():
	# Don't save if the changelog is empty
	if _edit.text.strip_edges().empty(): return
	get_fh().write_text(get_settings().get("changelog_path", ""), _edit.text)
	_anim.play("fade away")

func get_settings():
	return _doc.settings

func get_fh():
	return _doc.fh


func _on_Changelog_visibility_changed():
	if visible:
		load_changelog()
