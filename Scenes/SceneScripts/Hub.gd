extends Node2D

var bg_color: Color = Color.darksalmon


var scale_down_time: float = 0.05

func _ready():
	var save_file = File.new()
	if save_file.file_exists("user://Settings/bg_color.ryash"):
		save_file.open("user://Settings/bg_color.ryash", File.READ)
		bg_color = save_file.get_var()
	save_file.close()
	
	set_bg_color(bg_color)

func set_bg_color(color: Color):
	$NavBarBg.color = color
	$NavBarBg.color.a = 0.85
	
	$background.color = color


func _on_Home_mouse_entered():
#	$NavBarBg/Home/Sprite.scale = lerp($NavBarBg/Home/Sprite.scale, Vector2(0.6, 0.6), 0.2)
	var tween := create_tween()
	tween.tween_property($NavBarBg/Home/Sprite, "scale", Vector2(0.8, 0.8), scale_down_time)


func _on_Home_mouse_exited():
	var tween := create_tween()
	tween.tween_property($NavBarBg/Home/Sprite, "scale", Vector2(1, 1), scale_down_time)


func _on_Installs_mouse_entered():
	var tween := create_tween()
	tween.tween_property($NavBarBg/Installs/Sprite, "scale", Vector2(0.8, 0.8), scale_down_time)


func _on_Installs_mouse_exited():
	var tween := create_tween()
	tween.tween_property($NavBarBg/Installs/Sprite, "scale", Vector2(1, 1), scale_down_time)


func _on_Settings_mouse_entered():
	var tween := create_tween()
	tween.tween_property($NavBarBg/Settings/Sprite, "scale", Vector2(0.8, 0.8), scale_down_time)


func _on_Settings_mouse_exited():
	var tween := create_tween()
	tween.tween_property($NavBarBg/Settings/Sprite, "scale", Vector2(1, 1), scale_down_time)


func _on_Home_pressed():
	$Installs.visible = false
	$Settings.visible = false
	$Home.visible = true


func _on_Installs_pressed():
	$Settings.visible = false
	$Home.visible = false
	$Installs.visible = true


func _on_Settings_pressed():
	$Home.visible = false
	$Installs.visible = false
	$Settings.visible = true






