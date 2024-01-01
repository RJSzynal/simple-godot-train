extends Node

@export var car_count:int = 10
const train_vehicle_scene:PackedScene = preload("res://Scenes/Train/Vehicle.tscn")
const chase_camera_scene:PackedScene = preload("res://Demo/Scenes/ChaseCamera.tscn")
const CarriageTypes = preload("res://Scripts/Enums.gd").CarriageTypes
var train

func _ready():
	var train_layout = [CarriageTypes.ENGINE]
	for i in range(car_count):
		train_layout.append(CarriageTypes.PASSENGER)

	await get_tree().create_timer(1).timeout
	train = train_vehicle_scene.instantiate()
	train.initialise(
		'Train0',
		$Tracks/Track1,
		train_layout,
		700,
	)
	add_child(train)
	train.connect("train_info", Callable($HUD, "update_train_info"))
	var chase_camera = chase_camera_scene.instantiate()
	train.all_cars[0].add_child(chase_camera)
