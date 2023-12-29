# A set of wheels that follow along Tracks
#
# TrainCarriages generally have two of these
class_name TrainBogie
extends PathFollow2D

enum Directions {HEADWARD, TAILWARD}

var direction = Directions.TAILWARD
var current_track
var current_track_length
@onready var sprite = $Sprite2D

func initialise(new_name:String):
	name = new_name

func _ready():
	_update_sprite()

func _update_sprite():
	if sprite: sprite.flip_v = direction == Directions.HEADWARD

# Put the bogie on a track
func set_track(track:Track):
	if current_track : get_parent().remove_child(self)
	track.add_child(self)
	current_track = track
	current_track_length = track.get_length()

# Set the direction of travel along the track
func set_direction(new_direction:Directions):
	direction = new_direction
	_update_sprite()

func head_to_tail():
	set_direction(Directions.TAILWARD)

func tail_to_head():
	set_direction(Directions.HEADWARD)

# Place this bogie a specific distance behind another one
func follow(leader:TrainBogie, distance):
	set_track(leader.current_track)
	set_direction(leader.direction)
	progress = leader.progress
	move(-distance)

# Move by some distance
func move(distance):
	if !current_track: return
	var directional_distance = distance if direction == Directions.TAILWARD else -distance
	var target_progress = progress + directional_distance

	if target_progress > current_track_length:
		progress_ratio = 1
		current_track.emit_bogie_at_tail(self, target_progress - current_track_length, direction == Directions.TAILWARD)
	elif target_progress < 0:
		progress_ratio = 0
		current_track.emit_bogie_at_head(self, abs(target_progress), direction == Directions.HEADWARD)
	else:
		progress += directional_distance
