@tool
# A piece of track that TrainBogie nodes follow along
class_name Track
extends Path2D

signal bogie_at_head
signal bogie_at_tail

@export var crosstie_distance = 10
@export var enabled:bool = true
@onready var _crosstie_mesh_instance = $Crosstie
@onready var _crosstie_multimesh = $MultiMeshInstance2D

func _ready():
	_update_sprites()

# Connect the "from_side" of this track to the "to_side" of the other track
#
# This links both tracks to each other, so only call it once per connection
func link_track(other_track, from_side, to_side):
	connect("bogie_at_" + from_side, Callable(other_track, "enter_from_" + to_side))
	other_track.connect("bogie_at_" + to_side, Callable(self, "enter_from_" + from_side))

# A bogie enters from the head side
func enter_from_head(bogie:TrainBogie, remaining_distance, is_forward:bool):
	#print('%s entered from head of %s' % [bogie.name, get_pretty_name()])
	bogie.set_track(self)
	bogie.progress_ratio = 0
	bogie.head_to_tail() if is_forward else bogie.tail_to_head()
	bogie.move(remaining_distance if is_forward else -remaining_distance)

# A bogie enters from the tail side
func enter_from_tail(bogie:TrainBogie, remaining_distance, is_forward:bool):
	#print('%s entered from tail of %s' % [bogie.name, get_pretty_name()])
	bogie.set_track(self)
	bogie.progress_ratio = 1
	bogie.tail_to_head() if is_forward else bogie.head_to_tail()
	bogie.move(-remaining_distance if is_forward else remaining_distance)

# The bogie has reached the head
func emit_bogie_at_head(bogie, remaining_distance, is_forward:bool):
	#print('%s left from head of %s' % [bogie.name, get_pretty_name()])
	emit_signal("bogie_at_head", bogie, remaining_distance, is_forward)

# The bogie has reached the tail
func emit_bogie_at_tail(bogie, remaining_distance, is_forward:bool):
	#print('%s left from tail of %s' % [bogie.name, get_pretty_name()])
	emit_signal("bogie_at_tail", bogie, remaining_distance, is_forward)

# Calculate and returnt he length of this track
func get_length():
	return(curve.get_baked_length())

func _update_sprites():
	$Line2D.points = curve.get_baked_points()
	_update_crossties()
	$HeadPoint.progress_ratio = 0
	$TailPoint.progress_ratio = 1

func _update_crossties():
	var crossties = _crosstie_multimesh.multimesh
	crossties.mesh = _crosstie_mesh_instance.mesh

	var curve_length = get_length()
	var crosstie_count = round(curve_length / crosstie_distance)
	crossties.instance_count = crosstie_count

	for i in range(crosstie_count):
		var t = Transform2D()
		var crosstie_position = curve.sample_baked((i * crosstie_distance) + crosstie_distance/(2 as float))
		var next_position = curve.sample_baked((i + 1) * crosstie_distance)
		t = t.rotated((next_position - crosstie_position).normalized().angle())
		t.origin = crosstie_position
		crossties.set_instance_transform_2d(i, t)

func get_pretty_name():
	var pretty_name = '%s%s' % [get_parent().name, name]
	return(pretty_name)
