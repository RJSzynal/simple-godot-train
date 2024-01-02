extends Control

signal train_info_toggled

@export var game_manager:GameManager
@onready var main_menu_button = $MenuPanel/VBoxContainer/MainMenuButton

var active:bool = false:
	get:
		return(active)
	set(value):
		show() if value else hide()
		mouse_filter = MOUSE_FILTER_STOP if value else MOUSE_FILTER_IGNORE
		active = value


# Called when the node enters the scene tree for the first time.
func _ready():
	active = game_manager.game_paused
	game_manager.connect('toggle_game_paused', _on_game_manager_toggle_game_paused)
	if game_manager.current_level == 'MainMenu':
		main_menu_button.hide()
	game_manager.connect('level_changed', _on_game_manager_level_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


#region Event Functions
func _on_game_manager_level_changed(_current_level:String, new_level:String):
	if new_level == 'MainMenu':
		main_menu_button.hide()
	else:
		main_menu_button.show()

func _on_game_manager_toggle_game_paused(is_paused:bool):
	active = is_paused

func _on_resume_button_pressed():
	game_manager.game_paused = false

func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_main_menu_button_pressed():
	game_manager.current_level = 'MainMenu'

func _on_info_button_toggled(toggled_on):
	emit_signal("train_info_toggled", toggled_on)
#endregion
