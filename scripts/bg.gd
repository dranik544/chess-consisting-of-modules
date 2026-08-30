extends Sprite


func _ready():
	get_tree().root.connect("size_changed", self, "_on_size_changed")
	for i in 3: yield(get_tree(), "idle_frame")
	_on_size_changed()

func _on_size_changed():
	scale = get_tree().root.size
	position = -get_tree().root.size / 2

func _process(delta):
	if material and material is ShaderMaterial:
		var current_time = material.get_shader_param("time_val")
		if current_time == null: current_time = 0.0
		
		var new_time = current_time + delta / 2
		material.set_shader_param("time_val", new_time)
		
		var spin_current = material.get_shader_param("spin_time")
		if spin_current == null:
			spin_current = 0.0
		material.set_shader_param("spin_time", spin_current + delta / 2)
