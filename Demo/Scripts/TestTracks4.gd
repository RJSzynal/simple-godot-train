extends Node

@export var car_count:int = 10
@onready var chase_camera = $ChaseCamera
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
		700,
	)
	add_child(train)
	train.connect("train_info", Callable($HUD, "update_train_info"))
	remove_child(chase_camera)
	train.all_cars[0].add_child(chase_camera)
