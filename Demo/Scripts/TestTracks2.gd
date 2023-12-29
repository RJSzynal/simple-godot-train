extends Node

@export var car_count:int = 6
const train_vehicle_scene:PackedScene = preload("res://Scenes/Train/Vehicle.tscn")
const CarriageTypes = preload("res://Scripts/Enums.gd").CarriageTypes
var train

func _ready():
	var train_layout = [CarriageTypes.ENGINE]
	for i in range(car_count):
		train_layout.append(CarriageTypes.PASSENGER)

	train = train_vehicle_scene.instantiate()
	train.initialise(
		'Train0',
		$Tracks/Track,
		train_layout,
		500,
	)
	add_child(train)
	train.connect("train_info", Callable($HUD, "update_train_info"))
