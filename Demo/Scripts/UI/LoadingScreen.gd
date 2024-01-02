extends Control

const fade_speed:float = 0.2

@export var game_manager:GameManager
@onready var translucency:ColorRect = $Translucency

var active:bool = false:
	get = get_active, set = set_active


func _ready():
	active = game_manager.game_loading

func get_active():
	return(active)

func set_active(value:bool):
	if active == value: return
	active = value
	var callback = Callable(self, &'print')
	callback.bind('tween complete')
	if value:
		show()
		var tween = create_tween()
		tween.tween_property(translucency, "color:a", 1.0, fade_speed)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_callback(callback)
	else:
		var tween = create_tween()
		tween.tween_property(translucency, "color:a", 0.0, fade_speed)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_callback(callback)
	await get_tree().create_timer(fade_speed).timeout
	if not value:
		hide()
