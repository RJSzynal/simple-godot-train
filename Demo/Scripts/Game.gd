# Runs the demo's main scene
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
		$Tracks/Track1,
		train_layout,
		400,
	)
	add_child(train)

func _on_Button_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/TestTracks1.tscn"))

func _on_Button2_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/TestTracks2.tscn"))

func _on_Button3_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/TestTracks3.tscn"))

func _on_Button4_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/TestTracks4.tscn"))

func _on_Button5_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/TestTracks5.tscn"))

func _on_Button6_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/TestTracks6.tscn"))
