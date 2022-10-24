extends Node2D

func update_downloaded_versions():
	$version.clear()
	var installed_checker: Directory = Directory.new()
	installed_checker.open("user://Versions/")
	installed_checker.list_dir_begin()
	var file_name = installed_checker.get_next()
	
	while file_name != "":
		if !file_name.begins_with("Godot"):
			file_name = installed_checker.get_next()
			continue
		
		$version.add_item(file_name)
		file_name = installed_checker.get_next()

func _ready():
	update_downloaded_versions()


func _on_Timer_timeout():
	update_downloaded_versions()



func _on_create_pressed():
	var dir = Directory.new()
	
	if !dir.dir_exists("user://Projects/"):
		dir.make_dir("user://Projects/")
	
	if dir.dir_exists("user://Projects/" + $name.text) or $name.text == "":
		return
	dir.make_dir("user://Projects/" + $name.text)
	
	var file = File.new()
	print("user://Projects/" + $name.text + "/project.godot")
	
	file.open("user://Projects/" + $name.text + "/project.godot", File.WRITE)
	file.store_line("[application]")
	file.store_line("config/name=" + '"' + $name.text + '"')
	file.close()
	
	var path = str(OS.get_user_data_dir()) + "/Versions/" + str($version.text)
	
	var project_file = str(OS.get_user_data_dir()) + "/Projects/" + str($name.text) + "/project.godot"
	
	OS.execute(path, ['-e', project_file], false)
