@tool

class_name TrackJunction
extends Area2D

@export var parent:NodePath
@export var side:String
@export var enabled:bool = true
@onready var track_switch = get_node(parent)

func _on_TrackJunction_area_entered(junction:TrackJunction):
	#print('%s%s: %s' % [get_parent().get_parent().name, name,  'enabled' if enabled else 'disabled'])
	#print('%s%s: %s' % [junction.get_parent().get_parent().name, junction.name,  'enabled' if junction.enabled else 'disabled'])
	if !enabled || !junction.enabled: return
	if junction.is_in_group("track_junctions") && junction.enabled:
		track_switch.link_track(junction.track_switch, side, junction.side)
		enabled = false
		junction.enabled = false
