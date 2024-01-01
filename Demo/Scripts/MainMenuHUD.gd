# Runs the demo's main menu HUD
extends Node

func _on_button_1_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/Levels/TestTracks1.tscn"))

func _on_button_2_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/Levels/TestTracks2.tscn"))

func _on_button_3_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/Levels/TestTracks3.tscn"))

func _on_button_4_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/Levels/TestTracks4.tscn"))

func _on_button_5_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/Levels/TestTracks5.tscn"))

func _on_button_6_pressed():
	get_tree().change_scene_to_packed(load("res://Demo/Scenes/Levels/TestTracks6.tscn"))

func _on_button_quit_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
