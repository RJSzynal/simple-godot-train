extends Camera2D

@export var max_zoom:float = 1.5
@export var min_zoom:float = 0.5
@export var zoom_step:float = 0.05
@export var zoom_ratio:float = 0.0015 # increase zoom by 25%/second

var desired_zoom:float = zoom.x

func _process(delta):
	if zoom.x != desired_zoom:
		zoom.x = clamp(_update_zoom(delta), min_zoom, max_zoom)
		zoom.y = zoom.x

func _update_zoom(delta):
	var zoom_speed = zoom_ratio * delta * (max_zoom - min_zoom)
	var zoom_change = desired_zoom - zoom.x
	var normalised_zoom_change = clamp(zoom_change, -zoom_speed, zoom_speed)
	if abs(normalised_zoom_change) < 0.01:
		return(desired_zoom)
	else:
		return(zoom.x + normalised_zoom_change)

func _input(event):
	if event.is_action_pressed("zoom_in") || event.is_action_pressed("zoom_out"):
		_update_desired_zoom()
	elif Input.is_action_pressed("pan") && event is InputEventMouseMotion:
		_update_pan(event)

func _update_desired_zoom():
	if Input.get_axis("zoom_out", "zoom_in") > 0:
		desired_zoom = clamp(desired_zoom * (1 + zoom_step), min_zoom, max_zoom)
	else:
		desired_zoom = clamp(desired_zoom * (1 - zoom_step), min_zoom, max_zoom)

func _update_pan(event):
	offset -= event.relative.rotated(global_rotation)
	offset.x = clamp(offset.x, -1100, 1100)
	offset.y = clamp(offset.y, -630, 630)
