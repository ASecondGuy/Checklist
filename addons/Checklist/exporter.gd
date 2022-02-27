tool
extends Node


# first argument must be preset name, second must be debug, 
func threaded_export(val:Array):
	print("Threaded export for %s started" % val[0])
	var out := []
	var args = [
		'--no-window',
		'--export',
		val[0],
	]
	if val[1]: args[1] = '--export-debug'
	var exit = OS.execute(OS.get_executable_path(), args, true, out)
	if exit != OK:
		push_error("Export of %s failed with Errorcode %s \n printing Output:" % [val[0], exit])
	else:
		print("Export of %s complete" % val[0])
