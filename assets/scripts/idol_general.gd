
extends RigidBody2D

onready var my_image= get_node("eidolin_sprite")

var state="air"
var flags=[]
export var idol_type=""

#stats, to be overridden by the identity node.
var stat_dive_speed= 400
var stat_leap_height= 150
var stat_leap_width= 75
var stat_dive_length= 45

#vars to track state changes
var dive_time=0


func _ready():
	if (idol_type==""):
		idol_type="emerald"
	action_climb()
	set_process(true)
	pass
	
func _process(delta):
	update_states()
	
func action_dive():
	if(state=="air"):
		self.set_linear_velocity(Vector2(0,stat_dive_speed))
		dive_time=stat_dive_length
		state="dive"
		if (my_image.has_method("start_dive")):
				my_image.start_dive()
	

func action_leap(facing):
	if (state == "air"):
		#cancel countering velocity, for quick turns
		 if (! sign(facing)==sign(self.get_linear_velocity().x)):
				self.set_linear_velocity(Vector2(0,self.get_linear_velocity().y))
		 self.apply_impulse(Vector2(0,0), Vector2(stat_leap_width * facing, 0))

		
func action_climb():
	if(state=="air"):

		self.set_linear_velocity(Vector2(self.get_linear_velocity().x,0))
		self.apply_impulse(Vector2(0,0), Vector2(0, -stat_leap_height))
		print("climb")
		if my_image.has_method("climb"):
			my_image.climb()
			

func action_die(killer):
	#go limp and set state and image
	self.set_mode(MODE_RIGID)
	self.apply_impulse(self.get_pos(),killer.get_pos())
	if my_image.has_method("die"):
		my_image.die(killer)
	state="dead"
	print("A player was defeated")
		

func update_states():
	if (state=="dive"):
		dive_time-=1
		if (dive_time <=0):
			state= "air"
			self.set_linear_velocity(Vector2(self.get_linear_velocity().x,0))
			if (my_image.has_method("end_dive")):
				my_image.end_dive()
			print("ended dive")
			


#collisions
func _on_eidolin_body_body_enter( body ):
	if body.is_in_group("idols"):
		if (body.get_pos().y<self.get_pos().y):
			self.action_die(body)
