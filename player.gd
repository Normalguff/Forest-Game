# * ~ . HANDLES PLAYER BEHAVIOUR . ~ *

class_name Player
extends CharacterBody2D

@export var speed = 1

@onready var interact_ui = $InteractUI
@onready var interact_label = $InteractUI/ColorRect/Label
@onready var inventory_ui = $InventoryUI
@onready var inventory_hotbar = $InventoryHotbar
@onready var axe = $AxeTool
@onready var collision = $CollisionPolygon2D
@onready var weapon_collision = $AxeTool/Area2D/CollisionShape2D
@onready var timer = $Timer

@onready var slot_scene = preload("res://Scenes/hotbar_slot.tscn")

var facing = (null)
var hit_object = false

var selected_item = (null)

var current_energy: int = 100

func _ready():
	Global.set_player_reference(self)
	weapon_collision.set_deferred("disabled", true)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	

func _physics_process(delta):
	get_input()

	if Input.is_action_pressed("right") and hit_object == false:
		position.x += 1.5
		position.y += 0.75
	elif Input.is_action_pressed("left") and hit_object == false:
		position.x -= 1.5
		position.y -= 0.75
	elif Input.is_action_pressed("up") and hit_object == false:
		position.x += 1.5
		position.y -= 0.75
	elif Input.is_action_pressed("down") and hit_object == false:
		position.x -= 1.5
		position.y += 0.75
	
	move_and_slide()

@onready var _animated_sprite = $AnimationPlayer


# WALKING ANIMATIONS
func _process(_delta):
	if Input.is_action_pressed("right"):
		_animated_sprite.play("walk_right")
		collision.position = Vector2(4, 7)
	if Input.is_action_just_released("right"):
		_animated_sprite.play("idle_right")
		facing = ("right")

	if Input.is_action_pressed("left"):
		_animated_sprite.play("walk_back_left")
		collision.position = Vector2(-7,-1)
		
	if Input.is_action_just_released("left"):
		_animated_sprite.play("idle_left")
		facing = ("left")
		
	if Input.is_action_pressed("up"):
		_animated_sprite.play("walk_back_right")
		collision.position = Vector2(7, -1)
	if Input.is_action_just_released("up"):
		_animated_sprite.play("idle_up")
		facing = ("up")
		
	if Input.is_action_pressed("down"):
		_animated_sprite.play("walk_left")
		collision.position = Vector2(2, 12)
	if Input.is_action_just_released("down"):
		_animated_sprite.play("idle_down")
		facing = ("down")
		
	# TOOL ANIMATIONS
	if Input.is_action_just_pressed("use") and facing == ("right") and selected_item == ("tool"):
		_animated_sprite.play("axe_swing_right")
		axe.visible = true
		weapon_collision.set_deferred("disabled", false)
		if _animated_sprite.animation_finished:
			reduce_energy()
		
	if Input.is_action_just_released("use") and facing == ("right"):
		_animated_sprite.play("idle_right")
		axe.visible = false
		weapon_collision.set_deferred("disabled", true)
		timer.stop()
		
	if Input.is_action_just_pressed("use") and facing == ("down") and selected_item == ("tool"):
		_animated_sprite.play("axe_swing_left")
		axe.visible = true
		weapon_collision.set_deferred("disabled", false)
		if _animated_sprite.animation_finished:
			reduce_energy()
		
	if Input.is_action_just_released("use") and facing == ("down"):
		_animated_sprite.play("idle_down")
		axe.visible = false
		weapon_collision.set_deferred("disabled", true)
		timer.stop()
	
# INVENTORY
func _input(event):
	if event.is_action_pressed("inv"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused

func _on_close_button_pressed():
	inventory_ui.visible = false
	get_tree().paused = !get_tree().paused
	
func select_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.inventory[slot_index]
		if item != null:
			highlight_item(item)
		elif item == null:
			selected_item = ("null")
	
func highlight_item(item):
	var _item_type = item["type"]
	match item["type"]:
		"Tool":
			selected_item = ("tool")
		"Resource":
			selected_item = ("resource")
		"Consumable":
			selected_item = ("consumable")
		_:
			selected_item = ("null")
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		for i in range(Global.hotbar_size):
			if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
				select_hotbar_item(i)
				break
				

#COLLISION HANDLING

func _on_tree_body_entered(body):
	if body.is_in_group("Player"):
		hit_object = true

func _on_tree_body_exited(body):
	if body.is_in_group("Player"):
		hit_object = false

func _on_cabin_body_entered(body):
	if body.is_in_group("Player"):
		hit_object = true


func _on_cabin_body_exited(body):
	if body.is_in_group("Player"):
		hit_object = false
		

#ENERGY

func reduce_energy():
	var animation_length = _animated_sprite.get_current_animation_length()
	timer.wait_time = animation_length / 1.5
	timer.start()

func _on_timer_timeout():
	Global.update_energy()
