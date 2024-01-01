# A node that allows switching between two tracks
#
# Vehicles that enter at the head will be placed on the active track
class_name TrackSwitch2
extends Node2D

enum Directions {LEFT, RIGHT}

@export var direction = Directions.RIGHT
var end:String
@onready var checkbutton = $Button

func _ready():
	_update_checkbutton()

# Change the direction of the switch
func switch():
	if not _has_bogies_on():
		direction = Directions.RIGHT if direction == Directions.LEFT else Directions.LEFT
		get_node('../..').toggle_primary_track(end)
	_update_checkbutton()

func set_end(new_end:String):
	end = new_end

func _update_checkbutton():
	checkbutton.button_pressed = direction == Directions.RIGHT

# Check if the switch currently has bogies on it
func _has_bogies_on():
	for area in get_node('../TrackJunction').get_overlapping_areas():
		if area.get_parent().is_in_group('train_bogies'): return true

func _on_Button_pressed():
	switch()
