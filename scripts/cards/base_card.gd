# base_card.gd
extends TextureButton

export(String) var type
export(bool) var color
export(PackedScene) var piece
export(StreamTexture) var texture = null

onready var tween = $Tween

func _ready():
#	connect("focus_entered", self, "focus_entered_animation")
	connect("focus_exited", self, "focus_exited_animation")
	if texture: texture_normal = texture

func focus_entered_animation():
	tween.interpolate_property(self, "rect_position:y", rect_position.y, rect_position.y - (64.0 if color else -64.0), 0.15, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func focus_exited_animation():
	tween.interpolate_property(self, "rect_position:y", rect_position.y, 0.0, 0.15, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
