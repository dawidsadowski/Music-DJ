extends "res://scenes/DialogScript.gd"

var instrument_index
var column_no
var pressed_button_index = 0
var genre_index = 0 # Index based on genre. Eg: button 0 of genre 2. genre_index would be 0
var sample_category = 0

var column

onready var button_container = $VBoxContainer/ScrollContainer/VBoxContainer
onready var audio_player = $AudioStreamPlayer


func _ready():
	if !OS.is_ok_left_and_cancel_right():
		$VBoxContainer/HBoxContainer.move_child(
			$VBoxContainer/HBoxContainer/CancelButton,
			0
		)
		$VBoxContainer/HBoxContainer.move_child(
			$VBoxContainer/HBoxContainer/OkButton,
			2
		)
	
	# Create list
	var text = ["Groove 1", "Groove 2", "Salsa 1", "Salsa 2", "Reggae 1", "Reggae 2", "Techno 1", "Techno 2"]
	var category = ["Introduction", "Verse", "Chorus", "Solo"]
	var colors = Variables.colors
	var button_index = -1
	
	for i in 4:
		var separator = HSeparator.new()
		separator.set("custom_constants/separation", 10)
		separator.modulate = Color(1, 1, 1, 0.01)
		button_container.add_child(separator)
		
		var label = Label.new()
		label.text = category[i]
		label.theme_type_variation = "LabelSubtitle"
		button_container.add_child(label)
		
		var separator2 = HSeparator.new()
		button_container.add_child(separator2)
		
		# Icon
		var image = load("res://assets/mask.png")
		var texture = ImageTexture.new()
		var color = get_theme().get_color(
			Variables.category_names[i],
			"Tile"
		)
		#image.create(32, 32, false, Image.FORMAT_RGBA4444)
		image.lock()
		for v in 32:
			for h in 32:
				var current_pixel = image.get_pixel(h, v)
				image.set_pixel(h, v, colors[i] * current_pixel)
		image.unlock()
		texture.create_from_image(image)
		
		# Buttons
		for g in 8:
			button_index += 1
			var button_in_list = Button.new()
			button_in_list.text = " "+text[g]
			button_in_list.theme_type_variation = "ListItem"
			button_in_list.icon = texture
			button_in_list.align = Button.ALIGN_LEFT
			button_in_list.mouse_filter = Button.MOUSE_FILTER_PASS
			button_in_list.connect("pressed", self, "on_Button_selected", [button_index, g, i])
			button_in_list.name = str(button_index)
			button_in_list.focus_mode = Control.FOCUS_CLICK
			button_in_list.toggle_mode = true
			button_container.add_child(button_in_list)


func about_to_show(dim := true):
	column = main.get_node("HBoxContainer/StepContainer/HBoxContainer").get_child(column_no)
	
	# Set title
	var instrument = Variables.instrument_names[instrument_index]
	$VBoxContainer/Label.text = instrument + ", column " + str(column_no + 1)
	
	# Set button states
	var clear_button = get_node("VBoxContainer/HBoxContainer/ClearButton")
	var ok_button = get_node("VBoxContainer/HBoxContainer/OkButton")
	
	if main.song[instrument_index][column_no]:
		var selected_button = button_container.get_node(
			str(main.song[instrument_index][column_no] - 1)
		)
		selected_button.pressed = true
		selected_button.grab_focus()
		clear_button.disabled = false
		ok_button.disabled = false
	else:
		clear_button.disabled = true
		ok_button.disabled = true
	
	.about_to_show()


func on_Button_selected(index, _genre_index, _sample_category):
	if index == pressed_button_index:
		button_container.get_node(str(pressed_button_index)).pressed = true
	
	audio_player.stream = load("res://sounds/"+str(instrument_index)+"/"+str(index+1)+".ogg")
	audio_player.play()
	$VBoxContainer/HBoxContainer/OkButton.disabled = false
	pressed_button_index = index
	genre_index = _genre_index
	sample_category = _sample_category
	
	for i in button_container.get_children():
		if i is Button:
			if i.name == str(index):
				continue
			i.pressed = false


func _on_OkButton_pressed():
	if main.song[instrument_index][column_no] - 1 == pressed_button_index:
		hide()
		return

	column.set_tile(
		instrument_index,
		sample_category,
		str(genre_index + 1)
	)
	
	main.song[instrument_index][column_no] = pressed_button_index+1
	if not main.used_columns.has(column_no):
		main.used_columns.append(column_no)
	
	column_no = 0
	
	hide()


func _on_ClearButton_pressed():
	column.clear_tile(instrument_index)
	
	# If all buttons in a column are clear remove that column from the play list
	var falses = -1
	for i in 4:
		if main.song[i][column_no]:
			falses += 1
	if falses == 0:
		main.used_columns.erase(column_no)
	
	main.song[instrument_index][column_no] = 0

	hide()


func _on_CancelButton_pressed():
	hide()


func popup_hide(dim := true):
	$VBoxContainer/ScrollContainer.scroll_vertical = 0
	for i in button_container.get_children():
		if i is Button:
			i.pressed = false
	.popup_hide()

func get_theme():
	var control = self
	var theme = null
	while control != null && "theme" in control:
		theme = control.theme
		if theme != null: break
		control = control.get_parent()
	return theme
