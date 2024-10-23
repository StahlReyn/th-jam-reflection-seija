class_name MSExpiryTimer
extends MovementScript

@export var active : bool = true
@export var duration : float = 3.0

var elapsed_time : float = 0.0

func _init(duration : float, active : bool = true) -> void:
	self.active = active
	self.duration = duration

func _ready() -> void:
	elapsed_time = 0.0

func _physics_process(delta: float) -> void:
	if active:
		elapsed_time += delta
		if elapsed_time >= duration:
			print("Expiry Script Done")
			parent.call_deferred("queue_free")
