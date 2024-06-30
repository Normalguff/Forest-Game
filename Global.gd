extends Node

var inventory = []

signal inventory_updated
signal hotbar_inventory_updated

var spawnable_items = [
	{"type": "Consumable", "name": "Brown Mushroom", "description": "Health", "texture":
		preload("res://Art/Consumables/brown_mushroom.png")},
]

var player_node: Node = null
@onready var inventory_slot_scene = preload("res://Scenes/inventory_slot.tscn")
@onready var hotbar_slot_scene = preload("res://Scenes/hotbar_slot.tscn")
var hotbar_size = 6
var hotbar_inventory = []
var hotbar_assignable = false

func _ready():
	inventory.resize(12)
	hotbar_inventory.resize(hotbar_size)
	
func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["description"] == item["description"]:
			inventory[i]["quantity"] += item["quantity"]
			inventory_updated.emit()
			return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			return true
	return false
	
func remove_item(item_type, item_description):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item_type and inventory[i]["description"] == item_description:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func increase_inventory_size():
	inventory_updated.emit()
	
func set_player_reference(player):
	player_node = player

func adjust_drop_position(position):
	var radius = 50
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position
	
func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.global_position = drop_position
	get_tree().current_scene.add_child(item_instance)
	
func swap_inventory_items(index1, index2):
	if index1 < 0 or index1 > inventory.size() or index2 < 0 or index2 > inventory.size():
		return false
	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp
	inventory_updated.emit()
	return true
