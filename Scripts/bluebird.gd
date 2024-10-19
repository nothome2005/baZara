extends Node3D
var phone:bool = false

@onready var mpp: MPPlayer = get_parent().get_parent().get_parent()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(mpp.ma("phone")):
		if !phone:
			$AnimationPlayer.play("Turn_on")
			phone = true
		else:
			$AnimationPlayer.play("Turn_off")
			phone = false
