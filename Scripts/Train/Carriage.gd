# Sits on top of two TrainBogies to move along a Track
class_name TrainCarriage
extends Node2D

signal cargo_qty_changed

@export var carriage_length:int = 84
@export var head_length:int = 13
@export var tail_length:int = 13
@export var bogie_distance:int = carriage_length - head_length - tail_length
@export var num_bogies:int = 2

enum CargoFamilies { NONE, PASSENGERS, AGGREGATE }
@export var cargo_family:CargoFamilies = CargoFamilies.NONE
@export var cargo_capacity:int = 0
@export var cargo_mass:float = 0
@export var current_cargo_qty:int = 0

# Physics
@export var mass:float = 10
@export var air_density:float = 1.0
@export var velocity_multiplier:float = 1.5
@export var brake_application_speed:int = 5
@export var friction_coefficient:float = 0.1
@export var rolling_resistance_coefficient:float = 0.005
@export var air_resistance_coefficient:float = 0.10
@export var max_brake_force:int = 2
@export var max_force:float = 0

const bogie_scene: PackedScene = preload("res://Scenes/Train/Bogie.tscn")

var bogies:Array = []
@onready var body = $Body

func initialise(new_name:String):
	name = new_name
	bogies.resize(num_bogies)
	for index in range(num_bogies):
		var bogie = bogie_scene.instantiate()
		bogie.initialise('%sBogie%s' % [name, index])
		bogies[index] = bogie

func _process(_delta):
	_update_sprite()

func _update_sprite():
	if bogies.size() > 0:
		set_global_position(get_front_bogie().global_position)
		if body: body.look_at(get_back_bogie().global_position)

func get_mass():
	return(mass + (current_cargo_qty * cargo_mass))

func get_friction():
	var gravity:float = PhysicsServer2D.AREA_PARAM_GRAVITY as float/100
	var friction_force:float = friction_coefficient * get_mass() * gravity
	friction_force += rolling_resistance_coefficient * get_mass() * gravity

	return(friction_force)

func get_max_brake_force():
	return(max_brake_force)

func get_air_resistance_coefficient():
	return(air_resistance_coefficient)

func get_max_force():
	return(max_force)

func get_current_cargo_qty():
	return(current_cargo_qty)

func set_current_cargo_qty(quantity):
	current_cargo_qty = clamp(quantity, 0, cargo_capacity)
	emit_signal('cargo_qty_changed', get_current_cargo_qty())

func get_head_length():
	return(head_length)

func get_tail_length():
	return(tail_length)

func get_front_bogie():
	return(bogies[0])

func get_back_bogie():
	return(bogies[-1])

# Place this vehicle (and all of its bogies) on the track
func add_to_track(track:Path2D, progress = 1):
	if not progress: progress = 1
	get_front_bogie().set_track(track)
	get_front_bogie().progress = progress
	update_bogies()

func update_bogies():
	var previous_bogie = null
	for bogie in bogies:
		if previous_bogie:
			bogie.follow(previous_bogie, bogie_distance / (num_bogies - 1.0))
		previous_bogie = bogie
	set_global_position(get_front_bogie().global_position)
	if body: body.look_at(get_back_bogie().global_position)

# Follow another TrainCarriage
func follow_car(other_car):
	get_front_bogie().follow(other_car.get_back_bogie(), other_car.get_tail_length() + head_length)
	update_bogies()

func get_follow_track():
	return(get_back_bogie().current_track)

# Move by some distance
func move(distance:float):
	get_front_bogie().move(distance)
	update_bogies()
