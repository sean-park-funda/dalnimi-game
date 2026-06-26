extends Node2D

func _ready():
	UIAnimations.connect_buttons(self)
	_play_entry_animations()

func _play_entry_animations():
	$Title.modulate.a = 0.0
	$StartButton.scale = Vector2.ZERO
	UIAnimations.fly_in_from_top($Title, 60.0, 0.1)
	UIAnimations.pop_in($StartButton, 0.5)

func _on_start_button_pressed():
	SceneTransition.change_scene("res://scenes/Main.tscn")
