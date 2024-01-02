extends Control

@export var allows_camera_control = false

@onready var throttle_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Throttle')
@onready var force_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Force')
@onready var brake_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer7/Brake')
@onready var velocity_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/Velocity')
@onready var mass_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/Mass')
@onready var friction_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5/Friction')
@onready var drag_label = get_node('MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer6/Drag')

func _onReady():
	hide()

func update_train_info(info):
	throttle_label.text = "%0.1f%%" % (info["throttle"]*100)
	force_label.text = "%d/%d (%0.1f%%)" % [round(info["force_applied"]), info["force_max"], (info["force_applied"]/info["force_max"])*100]
	brake_label.text = "%d/%d (%0.1f%%)" % [round(info["applied_brake_force"]), info["max_brake_force"], (info["applied_brake_force"]/info["max_brake_force"])*100]
	velocity_label.text = "%0.1f" % (0 if abs(info["velocity"]) < 0.1 else info["velocity"])
	mass_label.text = "%0.1f" % info["total_mass"]
	friction_label.text = "%0.1f" % info["friction"]
	drag_label.text = "%0.1f" % info["drag"]
