# Runs the demo's main menu HUD
extends Node

signal button_pressed

func _on_button_1_pressed():
	emit_signal('button_pressed', 'TestTracks1')

func _on_button_2_pressed():
	emit_signal('button_pressed', 'TestTracks2')

func _on_button_3_pressed():
	emit_signal('button_pressed', 'TestTracks3')

func _on_button_4_pressed():
	emit_signal('button_pressed', 'TestTracks4')

func _on_button_5_pressed():
	emit_signal('button_pressed', 'TestTracks5')

func _on_button_6_pressed():
	emit_signal('button_pressed', 'TestTracks6')

func _on_button_quit_pressed():
	emit_signal('button_pressed', 'quit')
