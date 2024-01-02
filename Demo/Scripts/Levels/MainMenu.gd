# Runs the demo's main scene
extends Node

signal level_ready

@export var engine_count:int = 1
@export var car_count:int = 6
const train_vehicle_scene:PackedScene = preload("res://Scenes/Train/Vehicle.tscn")
var train

func _ready():
	var train_layout = []
	for i in range(engine_count):
		train_layout.append(TrainVehicle.CarriageTypes.ENGINE)
	for i in range(car_count):
		train_layout.append(TrainVehicle.CarriageTypes.PASSENGER)

	await get_tree().create_timer(1).timeout
	train = train_vehicle_scene.instantiate()
	train.initialise(
		'Train0',
		$Tracks/Track1,
		train_layout,
		400,
	)
	add_child(train)
	emit_signal('level_ready')
