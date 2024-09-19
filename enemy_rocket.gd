extends RigidBody2D

var debug = false

# Ship Stats
var Ship_Size = 20
var Forward_Thrusters = []
var Left_Thrusters = []
var Right_Thrusters = []

# Engine Stats
var Rear_Thruster_Imp = 50.0
var Rear_Thruster_Drain = 5.0

var Side_Thruster_Imp = 15.0
var Side_Thruster_Drain = 2.0
var Side_Truster_Offset = 13

var Correctional_Imp = 10.0
var Correctional_Drain = 0.5

# Start Stats
var dv = 0
var gravity = 9.81
var m_dry = 200
var m_fuel = 200
var m_total = m_dry + m_fuel
var velocity_vec = Vector2.ZERO
var forward_fire = false
var left_fire = false
var right_fire = false

# Movement Variables
var forward_threshold = 0.5
var turn_threshold = 0.25
var reverse_turn_threshold = 0.75
var reverse_turn_speed = 0.1

var angle_diff

# Onready's
@onready var GUI = "../Rocket Rigid/Camera2D/GUI/PanelContainer/VBoxContainer/"
@onready var player = get_node("../Rocket Rigid")

func _ready() -> void:
	linear_velocity = Vector2(0,-.1)
	assign_thrusters()

func _physics_process(delta: float) -> void:
	# Calc Direction to Player
	var player_position = player.global_position
	var dir_to_player = (player_position - global_position).normalized()

	# Calculate angle difference between enemy and player
	var target_rotation = dir_to_player.angle()
	angle_diff = ( target_rotation - rotation ) + PI/2

	movement(delta)

	thruster_visual()
	gui_update()

func movement(delta):
	if m_fuel <= 0:
		return
	
	# Forward
	if abs(angle_diff) < forward_threshold:
		m_fuel = m_fuel - ( Rear_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Rear_Thruster_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		
		velocity_vec = Vector2(0, -1).rotated(rotation)
		linear_velocity = linear_velocity + dv * velocity_vec
		
		forward_fire = true

	# Turn
	if abs(angle_diff) > reverse_turn_threshold or abs(angular_velocity) < reverse_turn_speed:
		m_fuel = m_fuel - ( Side_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Side_Thruster_Imp * gravity * log(m_total / m_new)
		var rot = 3* ( dv * m_total * Side_Truster_Offset ) / ( m_new * Ship_Size**2 )
		m_total = m_new
		
		# Choose turn direction
		if angle_diff < 0:
			angular_velocity = angular_velocity - rot
			right_fire = true
		if angle_diff > 0:
			angular_velocity = angular_velocity + rot
			left_fire = true

	# Reverse Turn
	if abs(angle_diff) <= reverse_turn_threshold and abs(angular_velocity) > reverse_turn_speed:
		m_fuel = m_fuel - ( Side_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Side_Thruster_Imp * gravity * log(m_total / m_new)
		var rot = 3* ( dv * m_total * Side_Truster_Offset ) / ( m_new * Ship_Size**2 )
		m_total = m_new
		
		# Choose turn direction
		if angle_diff > 0:
			angular_velocity = angular_velocity - rot
			right_fire = true
		if angle_diff < 0:
			angular_velocity = angular_velocity + rot
			left_fire = true

func assign_thrusters():
	for child in get_children():
		if child.is_in_group("Forward Thruster"):
			Forward_Thrusters.append(child)
		if child.is_in_group("Left Thruster"):
			Left_Thrusters.append(child)
		if child.is_in_group("Right Thruster"):
			Right_Thrusters.append(child)

func thruster_visual():
	if forward_fire == true:
		for i in Forward_Thrusters:
			i.color = Color(1,1,1,1)
	else:
		for i in Forward_Thrusters:
			i.color = Color(1,.27,1,1)

	if left_fire == true:
		for i in Left_Thrusters:
			i.color = Color(1,1,1,1)
	else:
		for i in Left_Thrusters:
			i.color = Color(1,.27,1,1)

	if right_fire == true:
		for i in Right_Thrusters:
			i.color = Color(1,1,1,1)
	else:
		for i in Right_Thrusters:
			i.color = Color(1,.27,1,1)

	forward_fire = false
	left_fire = false
	right_fire = false

func gui_update():
	if debug == false:
		return
	if debug == true:
		get_node(GUI +"Speed").text = "Speed: " + str(linear_velocity) + " m/s"
		get_node(GUI +"Rot Speed").text = "Rot Speed: " + str(angular_velocity) + " m/s"
		get_node(GUI +"Fuel").text = "Fuel: " + str(m_fuel) + " kg"
		get_node(GUI +"dv").text = "dv: " + str(dv) + " m/s"
		get_node(GUI +"v_vec").text = "Angle Diff: " + str(angle_diff)
