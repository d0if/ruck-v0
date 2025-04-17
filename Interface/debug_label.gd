extends RichTextLabel

func _process(delta: float) -> void:
	self.visible = DebugUtils.show_debug
	self.text = DebugUtils.debug_text
