extends RigidBody2D

# Ship Stats
var Ship_Size = 20
var Forward_Thrusters = []
var Left_Thrusters = []
var Right_Thrusters = []
var Left_Laterals = []
var Right_Laterals = []

# Engine Stats
var Rear_Thruster_Imp = 50.0
var Rear_Thruster_Drain = 5.0

var Side_Thruster_Imp = 15.0
var Side_Thruster_Drain = 2.0
var Side_Truster_Offset = 13

var Lateral_Imp = 10.0
var Lateral_Drain = 0.5

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
var left_lat_fire = false
var right_lat_fire = false

# Onready's
@onready var GUI = "Camera2D/GUI/PanelContainer/VBoxContainer/"

func _ready() -> void:
	linear_velocity = Vector2(0,-.1)
	assign_thrusters()

func _physics_process(delta: float) -> void:
	movement(delta)

	thruster_visual()
	gui_update()

func movement(delta):
	if m_fuel <= 0:
		return
	
	# Forward
	if Input.is_action_pressed("Rear Thruster") and m_fuel > 0:
		m_fuel = m_fuel - ( Rear_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Rear_Thruster_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		velocity_vec = Vector2(0, -1).rotated(rotation)
		linear_velocity = linear_velocity + dv * velocity_vec
		forward_fire = true

	# Left Rotate
	if Input.is_action_pressed("Left Thruster") and m_fuel > 0:
		m_fuel = m_fuel - ( Side_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Side_Thruster_Imp * gravity * log(m_total / m_new)
		var rot = 3* ( dv * m_total * Side_Truster_Offset ) / ( m_new * Ship_Size**2 )
		m_total = m_new
		angular_velocity = angular_velocity - rot
		left_fire = true

	# Right Rotate
	if Input.is_action_pressed("Right Thruster") and m_fuel > 0:
		m_fuel = m_fuel - ( Side_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Side_Thruster_Imp * gravity * log(m_total / m_new)
		var rot = 3* ( dv * m_total * Side_Truster_Offset ) / ( m_new * Ship_Size**2 )
		m_total = m_new
		angular_velocity = angular_velocity + rot
		right_fire = true

	# Left Lateral
	if Input.is_action_pressed("Left Lateral") and m_fuel > 0:
		m_fuel = m_fuel - ( Lateral_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Lateral_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		velocity_vec = Vector2(-1, 0).rotated(rotation)
		linear_velocity = linear_velocity + dv * velocity_vec
		left_lat_fire = true

	# Right Lateral
	if Input.is_action_pressed("Right Lateral") and m_fuel > 0:
		m_fuel = m_fuel - ( Lateral_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Lateral_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		velocity_vec = Vector2(1, 0).rotated(rotation)
		linear_velocity = linear_velocity + dv * velocity_vec
		right_lat_fire = true

func assign_thrusters():
	for child in get_children():
		if child.is_in_group("Forward Thruster"):
			Forward_Thrusters.append(child)
		if child.is_in_group("Left Thruster"):
			Left_Thrusters.append(child)
		if child.is_in_group("Right Thruster"):
			Right_Thrusters.append(child)
		if child.is_in_group("Left Lateral"):
			Left_Laterals.append(child)
		if child.is_in_group("Right Lateral"):
			Right_Laterals.append(child)

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

	if left_lat_fire == true:
		for i in Left_Laterals:
			i.color = Color(1,1,1,1)
	else:
		for i in Left_Laterals:
			i.color = Color(1,.27,1,1)

	if right_lat_fire == true:
		for i in Right_Laterals:
			i.color = Color(1,1,1,1)
	else:
		for i in Right_Laterals:
			i.color = Color(1,.27,1,1)

	forward_fire = false
	left_fire = false
	right_fire = false
	left_lat_fire = false
	right_lat_fire = false

func gui_update():
	get_node(GUI +"Speed").text = "Speed: " + str(linear_velocity) + " m/s"
	get_node(GUI +"Rot Speed").text = "Rot Speed: " + str(angular_velocity) + " m/s"
	get_node(GUI +"Fuel").text = "Fuel: " + str(m_fuel) + " kg"
	get_node(GUI +"dv").text = "dv: " + str(dv) + " m/s"
	get_node(GUI +"v_vec").text = "v_vec: " + str(velocity_vec)
	
	# Arrow
	var dir_to_home = get_angle_to( Vector2(576, 324) )
	$Camera2D/GUI/Arrow.rotation = dir_to_home + PI/2
