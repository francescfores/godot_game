extends StateMachine

@export var ground_state : StateMachine
@export var idle_attack_3_state : StateMachine
var is_auroa_active

var timer: Timer
var interval: float = 0.15
var anim_length 
func _on_enter():
	_deactivate_auroa_material()
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('idle_attack_2')

	timer = Timer.new()
	timer.connect("timeout",Callable(self, "_on_timer_timeout"))
	timer.one_shot = true
	anim_length = animationPlayer.current_animation_length
	timer.wait_time = interval
	add_child(timer)
	if anim_length > timer.wait_time:
		timer.start(anim_length - timer.wait_time)
	else:
		print("Animation is too short for the pre-timeout duration")

	#blink_timer = Timer.new()
	#blink_timer.wait_time = blink_interval
	#blink_timer.connect("timeout",Callable(self, "_on_blink_timer_timeout"))
	#add_child(blink_timer)
func _on_timer_timeout():
	print("0.3 seconds before ddddddddddddthe animation ends")
	#animationPlayer.play('idle_attack_2')
	is_auroa_active=true
	
func state_process(delta):

	if is_auroa_active:
		_activate_auroa_material()
	else:
		_deactivate_auroa_material()
	
var combo = false
func state_input(event:InputEvent):
	if event.is_action_pressed("shoot" +  character.action_suffix) and is_auroa_active:
		combo = true
		pass
		#is_auroa_active=false
		
func _on_animation_finished_player_(anim_name):
	print(anim_name)
	if anim_name == 'idle_attack_2':
		#stop_blinking()
		is_auroa_active=false
		_deactivate_auroa_material()
		if combo:
			next_state = idle_attack_3_state
		else:	
			next_state = ground_state
		combo = false
func _activate_auroa_material():
	auroa_material.set("shader_param/aura_width", 0.4) # Ajusta el valor según tus necesidades
	auroa_material.set("shader_param/aura_color", Color(0.70, 0.0, 0, 1)) # Ajusta el color según tus necesidades

func _deactivate_auroa_material():
	auroa_material.set("shader_param/aura_width", 0.0) # O cualquier valor que "desactive" visualmente el shader






var blink_timer: Timer
var blink_interval: float = 0.5
var should_blink: bool = false
var wait_attack=0.4

func start_blinking():
	should_blink = true
	if blink_timer.is_stopped():
		blink_timer.start()

func stop_blinking():
	should_blink = false
	#sword.visible = false
	blink_timer.stop()

func _on_blink_timer_timeout():
	print('_on_blink_timer_timeout')
	if should_blink:
		character.visible = not character.visible
	else:
		character.visible = true
		blink_timer.stop()
		
