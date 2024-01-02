# Sits on top of two TrainBogies to move along a Track
class_name TrainVehicle
extends Node2D

signal train_info

enum CarriageTypes { ENGINE, PASSENGER }

const carriage_scene:Dictionary = {
	CarriageTypes.ENGINE: preload("res://Scenes/Train/Engine.tscn"),
	CarriageTypes.PASSENGER: preload("res://Scenes/Train/Passenger.tscn"),
}
# Train Layout - engines and carriages
@export var desired_layout:Array = []
var all_cars:Array = []

# Physics
@export var air_density:float = 1.0
@export var force_application_ratio:float = 0.5 # increase engine power by 50%/second
@export var brake_application_ratio:float = 1.0 # increase brake power by 100%/second
@export var throttle_application_speed:float = 0.4
@export var brake_application_speed:float = 2.0
@export var rolling_resistance_coefficient:float = 0.005 # Real is 1.5-2% of engine traction lost
var mass:int = 0
var air_resistance_coefficient:float = 0
var friction_force:float = 0
var throttle_position:float = 0
var applied_force:float = 0
var max_force:float = 0
var brake_position:float = 0
var applied_brake_force:float = 0
var max_brake_force:int = 0
var velocity:float = 0


func initialise(new_name:String, initial_track:Track, target_layout:Array = [], initial_progress = null):
	name = new_name
	for index in target_layout.size():
		var car_type:CarriageTypes = target_layout[index]
		var car = carriage_scene[car_type].instantiate()
		car.initialise('%sCar%s' % [name, index])
		all_cars.append(car)
		add_child(car)
		if index == 0:
			car.add_to_track(initial_track, initial_progress)
		else:
			var previous_car = all_cars[index-1]
			car.follow_car(previous_car)

	_update_air_resistance_coefficient()
	_update_mass()
	_update_max_force()
	_update_max_brake_force()
	_update_friction_force()

func _process(delta):
	_update_throttle_position(delta)
	_update_brake_position(delta)
	emit_signal("train_info", {
		"throttle": throttle_position,
		"force_applied": applied_force,
		"force_max": max_force,
		"brake_position": brake_position,
		"applied_brake_force": applied_brake_force,
		"max_brake_force": max_brake_force,
		"total_mass": mass,
		"velocity": velocity,
		"friction": friction_force,
		"drag": _drag_force(),
	})

# Apply forces
func _physics_process(delta):
	_update_applied_force(delta)
	_update_applied_brake_force(delta)
	#if velocity != 0 or applied_force != 0:
	_move_with_friction(delta)

# Set the "throttle lever" position
func _update_throttle_position(delta):
	if Input.is_action_pressed("speed_up"):
		throttle_position = min(throttle_position + throttle_application_speed * delta, 1)
	elif Input.is_action_pressed("slow_down"):
		throttle_position = max(throttle_position - throttle_application_speed * delta, -1)
	elif Input.is_action_pressed("cut_throttle"):
		throttle_position = 0
	elif Input.is_action_pressed("full_throttle"):
		throttle_position = 1
	elif Input.is_action_pressed("full_reverse"):
		throttle_position = -1

# Set the percent of the total force with which the brake is being applied
func _update_brake_position(delta):
	if Input.is_action_pressed("brake"):
		brake_position = clamp(brake_position + brake_application_speed * delta, 0, 1)
	elif brake_position > 0:
		brake_position = clamp(brake_position - brake_application_speed * delta, 0, 1)

# Move the front bogie by the applied force, minus friction forces
func _move_with_friction(delta):
	var resistance = friction_force + _drag_force() + (applied_brake_force * max_brake_force)
	if applied_force == 0 && abs(velocity) < resistance / mass * delta:
		velocity = 0
	else:
		if velocity > 0:
			velocity = velocity + ((applied_force - resistance) / mass * delta)
		elif velocity < 0:
			velocity = velocity + ((applied_force + resistance) / mass * delta)
		else:
			velocity = velocity + (applied_force / mass * delta)
	#_apply_brake(delta)
	move_all_bogies(velocity * delta)

# The air resistance force
func _drag_force():
	return (air_resistance_coefficient * air_density * (pow(velocity,2)/2))

# The rolling resistance force
func _rolling_resistance():
	return (rolling_resistance_coefficient * applied_force)

func move_all_bogies(distance):
	if distance == 0: return
	for car in all_cars:
		car.move(distance)

# Lerp the actual engine force from its current value to the throttle position
func _update_applied_force(delta):
	var target_force = max_force * throttle_position
	var force_application_speed = (force_application_ratio * delta) * max_force
	applied_force += clamp(target_force - applied_force, -force_application_speed, force_application_speed)
	if abs(applied_force) < 0.1: applied_force = 0

# Lerp the actual engine force from its current value to the throttle position
func _update_applied_brake_force(delta):
	var target_force = max_brake_force * brake_position
	var force_application_speed = (brake_application_ratio * delta) * max_brake_force
	applied_brake_force += clamp(target_force - applied_brake_force, -force_application_speed, force_application_speed)
	if abs(applied_brake_force) < 0.1: applied_brake_force = 0

func _update_air_resistance_coefficient():
	for car in all_cars:
		if air_resistance_coefficient == 0:
			air_resistance_coefficient = car.get_air_resistance_coefficient()
		else:
			air_resistance_coefficient += car.get_air_resistance_coefficient() * 0.5

func _update_mass():
	for car in all_cars:
		mass += car.get_mass()

func _update_max_force():
	for car in all_cars:
		max_force += car.get_max_force()

func _update_max_brake_force():
	for car in all_cars:
		max_brake_force += car.get_max_brake_force()

func _update_friction_force():
	for car in all_cars:
		friction_force += car.get_friction()
