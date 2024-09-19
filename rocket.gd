extends CharacterBody2D

var Rear_Thruster_Imp = 5.0
var Rear_Thruster_Drain = 20.0

var Side_Thruster_Imp = 5.0
var Side_Thruster_Drain = 20.0
var Side_Truster_Offset = 13

var Side_High_Truster_Offset = 2

var dv = 0
var gravity = 9.81
var m_dry = 200
var m_fuel = 200
var m_total = m_dry + m_fuel
var velocity_vec = Vector2.ZERO

@onready var GUI = "../GUI/PanelContainer/VBoxContainer/"

func _ready() -> void:
	velocity = Vector2(0,-.1)

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("Rear Thruster") and m_fuel > 0:
		m_fuel = m_fuel - ( Rear_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Rear_Thruster_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		velocity_vec = velocity.normalized()
		velocity = velocity + dv * velocity_vec
		gui_update()

	if Input.is_action_pressed("Left Thruster") and m_fuel > 0:
		m_fuel = m_fuel - ( Side_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Side_Thruster_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		rotation = rotation + PI + dv * Side_Truster_Offset
		gui_update()

	if Input.is_action_pressed("Left High") and m_fuel > 0:
		m_fuel = m_fuel - ( Side_Thruster_Drain * delta)
		var m_new = m_dry + m_fuel
		dv = Side_Thruster_Imp * gravity * log(m_total / m_new)
		m_total = m_new
		rotation = rotation + PI + dv * Side_High_Truster_Offset
		gui_update()

	if Input.is_action_pressed("ui_cancel"):
		rotation = 0

	move_and_slide()

func gui_update():
	get_node(GUI +"Speed").text = "Speed: " + str(velocity) + " m/s"
	get_node(GUI +"Fuel").text = "Fuel: " + str(m_fuel) + " kg"
	get_node(GUI +"dv").text = "dv: " + str(dv) + " m/s"
	get_node(GUI +"v_vec").text = "v_vec: " + str(velocity_vec)
