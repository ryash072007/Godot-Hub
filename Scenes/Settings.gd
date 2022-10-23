extends Node2D



	

func _on_ChooseColor_pressed():
	if $ChooseColor.text == "Select":
		$CP.visible = true
		$ChooseColor.text = "Save"
	else:
		$ChooseColor.text = "Saving"
		
		
		var dir = Directory.new()
		if !dir.dir_exists("user://Settings"):
			dir.make_dir("user://Settings")
		
		var save_file = File.new()
		save_file.open("user://Settings/bg_color.ryash", File.WRITE)
		save_file.store_var($CP/ColorPicker.color)
		save_file.close()
		
		$CP.visible = false
		$ChooseColor.text = "Select"


func _on_ColorPicker_color_changed(color):
	$"..".set_bg_color(color)
