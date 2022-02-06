tool
extends MarginContainer



onready var checklist = $TabContainer/Checklist/cont
onready var changelog := $TabContainer/Changelog/edit

var plugin : EditorPlugin
var settings : Dictionary
var fh 

func add_checklist(list:Array):
	delete_checklist()
	for item in list:
		if item.find("/")==-1:
			var check = CheckBox.new()
			check.text = item
			checklist.add_child(check)
		
		var dat = item.split("/")
		if dat[0]=="L":
			var lab = Label.new()
			lab.text = dat[1]
			checklist.add_child(lab)
		elif dat[0]=="M":
			var btn = Button.new()
			btn.text = dat[1]
			btn.connect("pressed", plugin, "execute_makro", [""])
			checklist.add_child(btn)
		elif dat[0]=="E":
			var btn = Button.new()
			btn.text = dat[1]
			btn.connect("pressed", plugin, "export_game", [false])
			checklist.add_child(btn)


func uncheck_checklist():
	for child in checklist.get_children():
		if child is CheckBox:
			child.pressed = false


func delete_checklist():
	# remove everything exep the important buttons
	for child in checklist.get_children().slice(1, checklist.get_child_count()-2):
		child.queue_free()

func load_changelog():
	var text = fh.read_text(settings.get("changelog_path", ""))
	if text == "": return
	
	changelog.text = text
	
	#move cursor to the end
	var lc :int = changelog.get_line_count()
	while lc > 0 and changelog.get_line(lc-1).strip_edges().empty():
		lc-=1
	changelog.cursor_set_line(lc)
	changelog.cursor_set_column(changelog.get_line(lc-1).length())
	
	changelog.fold_all_lines()

func save_changelog():
	# Don't save if the changelog is empty
	if changelog.text.strip_edges().empty(): return
	fh.write_text(settings.get("changelog_path", ""), changelog.text)
	$AnimationPlayer.play("fade away")
	##print("saved changelog")



func _on_OptionButton_pressed():
	# search for new checklists
	pass # Replace with function body.
