@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_description = ""
var scene_path: String = "res://Scenes/inventory_item.tscn"

@onready var icon_sprite = $Sprite2D

var player_in_range = false

func _ready():
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	
func _process(delta):
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture
		
	if player_in_range and Input.is_action_just_pressed("add"):
		pickup_item()

func pickup_item():
	var item = {
		"quantity": 1,
		"type": item_type,
		"name": item_name,
		"texture": item_texture,
		"description": item_description,
		"scene_path": scene_path
	}
	if Global.add_item(item):
		if Global.player_node:
			self.queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		body.interact_ui.visible = true
		body.interact_label.text = ("pick up")

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		body.interact_ui.visible = false
		
func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_description = data["description"]
	item_texture = data["texture"]
	
func initiate_items(type, name, description, texture):
	item_type = type
	item_name = name
	item_description = description
	item_texture = texture
