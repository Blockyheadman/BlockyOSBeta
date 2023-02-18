extends WindowDialog

signal window_closed
signal window_hidden

var window_anim_playable = true
var maximized = false
var prev_size = Vector2()
var prev_pos = Vector2()

var max_anim_done = true

var fling_speed := Vector2()
var window_resizing = false

func _ready():
	modulate = Color(0,0,0,0)
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "window_size_changed")
	
	self.rect_size = Vector2(240,0)
	self.rect_position = Vector2(get_viewport_rect().size.x/2.48, get_viewport_rect().size.y/2)
	get_close_button().hide()
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(self, "rect_position", Vector2((get_viewport_rect().size.x/2)-self.rect_size.x/0.89, (get_viewport_rect().size.y/3)/1.22), 0.75)
	tween.tween_property(self, "rect_position", Vector2(self.rect_position.x-152, self.rect_position.y-158), 0.75)
	tween.parallel().tween_property(self, "rect_size", Vector2(544, 320), 0.75)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1,1), 0.5)

func _process(_delta):
	if Global.fling_enabled == true:
		if $DebugLabel.visible == false and OS.has_feature("debug"):
			$DebugLabel.show()
		if prev_size != self.rect_size:
			window_resizing = true
		else:
			window_resizing = false
		fling_speed = Vector2(round(self.rect_position.x - prev_pos.x), round(self.rect_position.y - prev_pos.y))
		if window_resizing:
			$DebugLabel.text = "Resizing Window"
			pass
		else:
			$DebugLabel.text = "Fling: " + str(fling_speed)
			#fling_speed = Vector2(round(self.rect_position.x - prev_pos.x), round(self.rect_position.y - prev_pos.y))
	else:
		if $DebugLabel.visible == true:
			$DebugLabel.hide()
	
	if maximized == true && max_anim_done == true:
		rect_position = Vector2(0,20)
	
	elif maximized == false:
		self.prev_size = rect_size
		self.prev_pos = rect_position

func _gui_input(event):
	if Global.fling_enabled == true:
		if !maximized:
			if event is InputEventMouseButton:
				if event.button_index == 1:
					if event.pressed:
						window_resizing = true
					else:
						window_resizing = false
			
			if event.is_action_released("LMB"):
				if fling_speed.y <= -15:
					_on_MaximizeButton_pressed()
				elif fling_speed.y >= 15:
					_on_MinimizeButton_pressed()
				elif fling_speed.x >= 15:
					close_window_right()
				elif fling_speed.x <= -15:
					close_window_left()
			
			if event is InputEventScreenTouch:
				if !event.pressed:
					if fling_speed.y <= -20:
						_on_MaximizeButton_pressed()
					elif fling_speed.y >= 20:
						_on_MinimizeButton_pressed()
					elif fling_speed.x >= 20:
						close_window_right()
					elif fling_speed.x <= -20:
						close_window_left()
		elif maximized:
			if event.is_action_released("LMB"):
				if fling_speed.y >= 20:
					_on_MaximizeButton_pressed()
			if event is InputEventScreenTouch:
				if !event.pressed:
					if fling_speed.y >= 20:
						_on_MaximizeButton_pressed()

func _on_CloseButton_pressed():
	#maximized = false
	print("emitting signal with parameter " + self.name)
	emit_signal("window_closed", self.name)
	
	if maximized == false:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "close_anim_done")
		tween.tween_property(self, "rect_position", Vector2(self.rect_position.x+prev_size.x/3.6, self.rect_position.y+prev_size.y/3.6), 0.75)
		tween.parallel().tween_property(self, "rect_size", Vector2(240, 0), 0.75)
		tween.parallel().tween_property(self, "modulate", Color8(255,255,255,0), 0.75)
	elif maximized == true:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "close_anim_done")
		tween.tween_property(self, "rect_position", Vector2(get_viewport_rect().size.x/2-prev_size.x/3.6, get_viewport_rect().size.y/2-prev_size.y/3.6), 0.75)
		tween.parallel().tween_property(self, "rect_size", Vector2(240, 0), 0.75)
		tween.parallel().tween_property(self, "modulate", Color8(255,255,255,0), 0.75)

func close_window_left():
	maximized = false
	print("emitting signal with parameter " + self.name)
	emit_signal("window_closed", self.name)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.connect("finished", self, "close_anim_done")
	tween.tween_property(self, "rect_position", Vector2(0-self.rect_size.x, self.rect_position.y+158), 0.75)
	tween.parallel().tween_property(self, "rect_size", Vector2(240, 0), 0.75)
	tween.parallel().tween_property(self, "modulate", Color8(255,255,255,0), 0.75)

func close_window_right():
	maximized = false
	print("emitting signal with parameter " + self.name)
	emit_signal("window_closed", self.name)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.connect("finished", self, "close_anim_done")
	tween.tween_property(self, "rect_position", Vector2(get_viewport_rect().size.x+self.rect_size.x, self.rect_position.y+158), 0.75)
	tween.parallel().tween_property(self, "rect_size", Vector2(240, 0), 0.75)
	tween.parallel().tween_property(self, "modulate", Color8(255,255,255,0), 0.75)

func _on_MaximizeButton_pressed():
	if max_anim_done == true:
		if maximized == false:
			max_anim_done = false
			maximized = true
			
			self.resizable = false
			"""print(OS.window_size.x)
			self.rect_size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y-72)
			print(rect_size)
			self.rect_position = Vector2(0,20)"""
			
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.connect("finished", self, "maximize_anim_done")
			tween.tween_property(self, "rect_position", Vector2(0, 20), 0.5)
			tween.parallel().tween_property(self, "rect_size", Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y-72), 0.5)
		
		elif maximized == true:
			maximized = false
			
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "rect_position", prev_pos, 0.5)
			tween.parallel().tween_property(self, "rect_size", prev_size, 0.5)
			self.resizable = true

func _on_MinimizeButton_pressed():
	emit_signal("window_hidden", self, false)
	#self.hide()
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.connect("finished", self, "minimize_anim_done")
	tween.tween_property(self, "rect_position", Vector2(self.rect_position.x+152, get_viewport_rect().size.y), 0.75)
	tween.parallel().tween_property(self, "rect_size", Vector2(240, 0), 0.75)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1,0), 0.75)

func close_anim_done():
	self.queue_free()

func minimize_anim_done(): 
	self.hide()
	maximized = false

func maximize_anim_done():
	max_anim_done = true

func window_size_changed():
	if maximized == true:
		max_anim_done = false
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.connect("finished", self, "maximize_anim_done")
		tween.tween_property(self, "rect_position", Vector2(0, 20), 0.5)
		tween.parallel().tween_property(self, "rect_size", Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y-72), 0.5)
