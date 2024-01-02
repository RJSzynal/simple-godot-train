class_name GameManager
extends Node

signal toggle_game_paused(is_paused:bool)
signal toggle_game_loading(is_loading:bool)
signal level_changed(current_level:String, new_level:String)

@onready var train_data:Control = get_node('CanvasLayer/TrainData')
@onready var train_data_button:CheckButton = get_node('CanvasLayer/PauseMenu/MenuPanel/VBoxContainer/InfoButton')

var game_paused:bool = false:
	get:
		return(game_paused)
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal('toggle_game_paused', game_paused)

var current_level:String = 'MainMenu':
	get:
		return(current_level)
	set(new_level):
		await set_game_loading(true)
		remove_level(current_level)
		add_level(new_level)
		emit_signal('level_changed', current_level, new_level)
		current_level = new_level
		if game_paused: game_paused = false

var game_loading:bool = true:
	get = get_game_loading, set = set_game_loading


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior

func _input(event:InputEvent):
	if event.is_action_pressed('ui_cancel'):
		game_paused = !game_paused


func add_level(level:String):
	var level_scene = load('res://Demo/Scenes/Levels/%s.tscn' % level)
	var level_node = level_scene.instantiate()
	$WorldGrid.add_sibling(level_node)
	level_node.connect('level_ready', _on_level_ready)
	if level == 'MainMenu':
		add_main_menu_ui()
		train_data_button.button_pressed = false
		train_data_button.hide()
	else:
		remove_main_menu_ui()
		train_data_button.show()
		train_data_button.button_pressed = true
		level_node.connect('train_info', _on_level_train_info)

func remove_level(level:String):
	var level_node = get_node(level)
	remove_child(level_node)
	level_node.queue_free()

func add_main_menu_ui():
	var main_menu_ui_scene = load('res://Demo/Scenes/UI/MainMenu.tscn')
	var main_menu_ui = main_menu_ui_scene.instantiate()
	$CanvasLayer/TrainData.add_sibling(main_menu_ui)
	main_menu_ui.connect('button_pressed', _on_main_menu_button_pressed)

func remove_main_menu_ui():
	var main_menu_ui = get_node_or_null('CanvasLayer/MainMenu')
	if main_menu_ui:
		main_menu_ui.queue_free()

func get_game_loading():
	return(game_loading)

func set_game_loading(value:bool):
		game_loading = value
		emit_signal('toggle_game_loading', value)
		await get_node('CanvasLayer/LoadingScreen').set_active(value)

#region Event Functions
func _on_level_ready():
	game_loading = false

func _on_level_train_info(data:Dictionary):
	train_data.update_train_info(data)

func _on_pause_menu_train_info_toggled(toggled_on:bool):
		if toggled_on:
			train_data.show()
		else:
			train_data.hide()

func _on_main_menu_button_pressed(level:String):
	if level == 'quit':
		propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	else:
		current_level = level
#endregion
