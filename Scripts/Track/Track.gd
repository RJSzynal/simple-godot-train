@tool
# A piece of track that TrainBogie nodes follow along
class_name Track
extends Path2D

@export_range(5,15) var crosstie_distance = 10:
	set(value):
		if crosstie_distance == value: return
		crosstie_distance = clamp(value, 5, 15)
		_update_sprites()
var attached_tracks = {
	'head': {},
	'tail': {},
}
var switches = {}
var primary_tracks = {}
@onready var _crosstie_mesh_instance = $Crosstie
@onready var _crosstie_multimesh = $MultiMeshInstance2D
const switch_scene: PackedScene = preload("res://Scenes/Track/Switch2.tscn")


func _ready():
	$TailArrow.set_progress(get_length() - $HeadArrow.get_progress())
	_update_sprites()

func _process(_delta):
	if Engine.is_editor_hint():
		_update_sprites()
		if $TailPoint.get_progress_ratio() != 1: $TailPoint.set_progress_ratio(1)

func enable_remote_arrow(end:String, remote_track_name:String):
	var remote = attached_tracks[end].get(remote_track_name)
	remote.track.enable_arrow(remote.end)

func disable_remote_arrow(end:String, remote_track_name:String):
	var remote = attached_tracks[end].get(remote_track_name)
	remote.track.disable_arrow(remote.end)
	remote.track.z_index = 1

func light_remote_arrow(end:String, remote_track_name:String):
	var remote = attached_tracks[end].get(remote_track_name)
	remote.track.light_arrow(remote.end)

func unlight_remote_arrow(end:String, remote_track_name:String):
	var remote = attached_tracks[end].get(remote_track_name)
	remote.track.unlight_arrow(remote.end)
	remote.track.z_index = 0

func enable_arrow(end:String):
	var arrow = $HeadArrow/ButtonHeadPrimary if end == 'head' else $TailArrow/ButtonTailPrimary
	arrow.show()

func disable_arrow(end:String):
	var arrow = $HeadArrow/ButtonHeadPrimary if end == 'head' else $TailArrow/ButtonTailPrimary
	arrow.hide()

func light_arrow(end:String):
	var arrow = $HeadArrow/ButtonHeadPrimary if end == 'head' else $TailArrow/ButtonTailPrimary
	arrow.disabled = true

func unlight_arrow(end:String):
	var arrow = $HeadArrow/ButtonHeadPrimary if end == 'head' else $TailArrow/ButtonTailPrimary
	arrow.disabled = false

# Check if the switch junction currently has bogies on it
func _has_bogies_on(end:String):
	var junction = $HeadPoint/TrackJunction if end == 'head' else $TailPoint/TrackJunction
	for area in junction.get_overlapping_areas():
		if area.get_parent().is_in_group('train_bogies'): return true

func set_remote_primary_track(end:String, force:bool = false):
	var remotes = attached_tracks[end]
	for key in remotes:
		var remote = remotes[key]
		remote.track.set_primary_track(remote.end, name, force)

func set_primary_track(end:String, new_track_name:String, force:bool = false):
	if not force && _has_bogies_on(end): return
	if primary_tracks.has(end):
		unlight_remote_arrow(end, primary_tracks[end])
	light_remote_arrow(end, new_track_name)
	primary_tracks[end] = new_track_name

func unset_primary_track(end:String):
	if primary_tracks.has(end):
		unlight_remote_arrow(end, primary_tracks[end])
		primary_tracks.erase(end)

func remove_primary_track(end:String):
	var num_tracks = attached_tracks[end].size()
	if num_tracks > 0:
		var all_track_names = attached_tracks[end].keys()
		set_primary_track(end, all_track_names[0], true)
	else:
		unset_primary_track(end)

func attach_to_end(end:String, remote_track:Track, remote_track_end:String):
	if not attached_tracks[end].has(remote_track.name):
		attached_tracks[end][remote_track.name] = {'track': remote_track, 'end': remote_track_end}
		var num_tracks = attached_tracks[end].size()
		if num_tracks == 1:
			set_primary_track(end, remote_track.name, true)
		if num_tracks > 1:
			enable_all_arrows(end)

func detach_from_end(end:String, remote_track:Track):
	if attached_tracks[end].has(remote_track.name):
		attached_tracks[end].erase(remote_track.name)
		if primary_tracks[end] == remote_track.name:
			remove_primary_track(end)
		var num_tracks = attached_tracks[end].size()
		if num_tracks == 1:
			disable_all_arrows(end)

# A bogie enters from the head side
func enter_from_end(bogie:TrainBogie, end:String, remaining_distance:float, is_tailward:bool):
	bogie.set_track(self)
	bogie.set_progress_ratio(0 if end == 'head' else 1)
	if is_tailward:
		bogie.head_to_tail()
	else:
		bogie.tail_to_head()
	bogie.move(remaining_distance)

# The bogie has reached the end of the track
func exit_from_end(bogie:TrainBogie, end:String, remaining_distance:float, is_tailward:bool):
	if attached_tracks[end].size() == 0:
		push_error('%s %s is not attached to any other track' % [name, end])
	var destination = attached_tracks[end].get(primary_tracks[end])
	if end == destination.end: is_tailward = not is_tailward
	destination.track.enter_from_end(bogie, destination.end, remaining_distance, is_tailward)

func enable_all_arrows(end:String):
	for remote_track_name in attached_tracks[end].keys():
		enable_remote_arrow(end, remote_track_name)

func disable_all_arrows(end:String):
	for remote_track_name in attached_tracks[end].keys():
		disable_remote_arrow(end, remote_track_name)

func disable_switch(end:String):
	if switches.has(end):
		switches[end].queue_free()
		switches.erase(end)

# Calculate and return the length of this track
func get_length():
	return(curve.get_baked_length())

func _update_sprites():
	$Line2D.points = curve.get_baked_points()
	_update_crossties()
	$HeadPoint.set_progress_ratio(0)
	$TailPoint.set_progress_ratio(1)

func _update_crossties():
	var crossties = _crosstie_multimesh.multimesh
	crossties.mesh = _crosstie_mesh_instance.mesh

	var curve_length = get_length()
	var crosstie_count = round(curve_length / crosstie_distance)
	crossties.instance_count = crosstie_count

	for i in range(crosstie_count):
		var t = Transform2D()
		var crosstie_position = curve.sample_baked((i * crosstie_distance) + crosstie_distance/2.0)
		var next_position = curve.sample_baked((i + 1) * crosstie_distance)
		t = t.rotated((next_position - crosstie_position).normalized().angle())
		t.origin = crosstie_position
		crossties.set_instance_transform_2d(i, t)

func _on_button_tail_primary_pressed():
	set_remote_primary_track('tail')

func _on_button_head_primary_pressed():
	set_remote_primary_track('head')

func _on_area_2d_tail_arrow_area_entered(area):
	if not area.get_parent().is_in_group('train_bogies'): return
	set_remote_primary_track('tail', true)

func _on_area_2d_head_arrow_area_entered(area):
	if not area.get_parent().is_in_group('train_bogies'): return
	set_remote_primary_track('head', true)
