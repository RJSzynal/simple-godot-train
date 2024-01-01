class_name TrackJunction
extends Area2D

@export var end:String
var track

## Main functions

func _ready():
	track = get_node('../..')
	monitorable = true
	monitoring = true

## Utility functions

# Normalize a rotation to within 0 and a full rotation
func normalise_rotation(this_rotation):
	while this_rotation < 0: this_rotation += TAU
	while this_rotation > TAU: this_rotation -= TAU
	return(this_rotation)

## Event functions

func _on_TrackJunction_area_entered(junction):
	var local_rotation = normalise_rotation(global_rotation)
	var remote_rotation = normalise_rotation(junction.global_rotation)
	# Calculate the
	var global_rotation_diff = max(local_rotation, remote_rotation) - min(local_rotation, remote_rotation)

	if junction.is_in_group("track_junctions") && global_rotation_diff > PI/4 && global_rotation_diff < PI + (PI/4):
		track.attach_to_end(end, junction.track, junction.end)

func _on_TrackJunction_area_exited(junction):
	if junction.is_in_group("track_junctions") :
		track.detach_from_end(end, junction.track)
