extends MarginContainer
@export var active:bool
var time
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time = Time.get_time_dict_from_system()
	$Label.text = "%02d:%02d" % [time.hour, time.minute]

func _on_timer_timeout() -> void:
	time = Time.get_time_dict_from_system()
	$Label.text = "%02d:%02d" % [time.hour, time.minute]
