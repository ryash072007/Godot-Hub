extends Node2D

var download_repo: String = "https://downloads.tuxfamily.org/godotengine/"

var second_level_urls := {}


var versions := []

func _ready():
	get_versions()
	update_downloaded_versions()

func update_downloaded_versions():
	$ItemList.clear()
	var installed_checker: Directory = Directory.new()
	installed_checker.open("user://Versions/")
	installed_checker.list_dir_begin()
	var file_name = installed_checker.get_next()
	
	while file_name != "":
		if !file_name.begins_with("Godot"):
			file_name = installed_checker.get_next()
			continue
		
		$ItemList.add_item(file_name)
		versions.append(file_name)
		file_name = installed_checker.get_next()



var is_installing := false

func get_versions():
#	index = -1
	second_level_urls.clear()
	
	var first_request := HTTPRequest.new()
	add_child(first_request)
	first_request.request(download_repo)
	
	var first_parser := XMLParser.new()
	first_parser.open_buffer(yield(first_request, "request_completed")[3])
	
	var versionList = []
	
	while first_parser.read() != ERR_FILE_EOF:
		if first_parser.get_node_name() == "a":
			var value = first_parser.get_named_attribute_value_safe("href")
			
			if value.substr(0, 1) in ['3', '4']:
				versionList.push_front(value)
	$versionSelect.add_item("Select")
	for version in versionList:
		$versionSelect.add_item(version.replace('/', ''))


func _on_versionSelect_item_selected(_index):
	second_level_urls.clear()
	$subversionSelect2.clear()
	$subversionSelect2.text = "Initialising"
#	index = _index
	yield(second_processing(_index), "completed")
	process_urls()

func process_urls():
	for key in second_level_urls.keys():
		$subversionSelect2.add_item(key)

func second_processing(index):
	var selected_value: String = $versionSelect.get_item_text(index)
	if selected_value == "Select": return
#	print(selected_value)
	
	var second_request := HTTPRequest.new()
	add_child(second_request)
	
	var new_url := download_repo + selected_value + '/'
	
	var err = second_request.request(new_url)
	
	var second_parser := XMLParser.new()
	second_parser.open_buffer(yield(second_request, "request_completed")[3])
	
	while second_parser.read() != ERR_FILE_EOF:
		if second_parser.get_node_name() == "a":
			var value = second_parser.get_named_attribute_value_safe("href")
			
			var new_new_url = false
			
			
			
			if "mono" in value:
				new_new_url = new_url + value
			elif "rc" in value:
				new_new_url = new_url + value
			elif "alpha" in value:
				new_new_url = new_url + value
			elif "beta" in value:
				new_new_url = new_url + value
			elif "stable_win64" in value:
				second_level_urls['stable'] = new_url + value
			
			if new_new_url:
#				print(value)
				yield(third_processing(new_new_url, value), "completed")

func third_processing(url: String, _name: String):
	var request := HTTPRequest.new()
	add_child(request)
	
	var err = request.request(url)
	
	var parser := XMLParser.new()
	parser.open_buffer(yield(request, "request_completed")[3])
	
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_name() == "a":
			var value = parser.get_named_attribute_value_safe("href")
			if "win64" in value:
#				print(value)
				second_level_urls[_name.replace('/', '')] = url + value
			elif "mono/" in value:
#				print(value)
				yield(fourth_processing(url + value, _name.replace('/', ' ') + value), "completed")

func fourth_processing(url: String, _name: String):
	var request := HTTPRequest.new()
	add_child(request)
	
	var err = request.request(url)
	
	var parser := XMLParser.new()
	parser.open_buffer(yield(request, "request_completed")[3])
	
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_name() == "a":
			var value = parser.get_named_attribute_value_safe("href")
			if "win64" in value:
#				print(value)
				second_level_urls[_name.replace('/', '')] = url + value


func _on_installBtn_pressed():
	if $subversionSelect2.text == "Initialising": return
	if is_installing: return
	$installBtn.text = "Downloading"
	is_installing = true
	var download_url: String = second_level_urls[$subversionSelect2.text]
	
	var dir = Directory.new()
	dir.make_dir_recursive("user://Downloads")
	
	var downloader := HTTPRequest.new()
	add_child(downloader)
	downloader.download_file = "user://Downloads/" + download_url.substr(download_url.find_last('/') + 1)
	downloader.request(download_url)
	yield(downloader, "request_completed")
#	print("downloaded")
	
	dir.make_dir_recursive("user://Versions/")
	$installBtn.text = "Installing"
	var unzipper = load("res://GDunzip_Custom/Unzip.gd").new()
	unzipper.unzip("user://Downloads/" + download_url.substr(download_url.find_last('/') + 1), "user://Versions/")
	$installBtn.text = "Install"
	is_installing = false
	
	update_downloaded_versions()


func _on_rc_toggled(button_pressed):
	show_in_list("rc", button_pressed)

func _on_alpha_toggled(button_pressed):
	show_in_list("alpha", button_pressed)


func _on_beta_toggled(button_pressed):
	show_in_list("beta", button_pressed)


func _on_stable_toggled(button_pressed):
	show_in_list("stable", button_pressed)


func _on_mono_toggled(button_pressed):
	show_in_list("mono", button_pressed)

func show_in_list(_name: String, show: bool):
	if !show:
		var delete_indices := []
		var indices = $subversionSelect2.get_item_count()
		for i in range(indices):
			var value = $subversionSelect2.get_item_text(i)
			if _name in value:
				delete_indices.push_front(i)
		
		for i in delete_indices:
			$subversionSelect2.remove_item(i)
	elif show:
		for key in second_level_urls.keys():
			if _name in key:
				$subversionSelect2.add_item(key)


func _on_OPM_pressed():
	if $ItemList.is_anything_selected():
		var path = str(OS.get_user_data_dir()) + "/Versions/" + str($ItemList.get_item_text($ItemList.get_selected_items()[0]))
		print(path)
		OS.execute(path, ['-p'], false)
#		OS.shell_open("user://Versions/" + $ItemList.get_item_text($ItemList.get_selected_items()[0]))
