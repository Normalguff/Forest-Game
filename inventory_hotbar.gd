extends Control

@onready var hotbar_container = $HBoxContainer
@onready var slot_scene = preload("res://Scenes/hotbar_slot.tscn")
@onready var inventory = preload("res://Scenes/inventory_ui.tscn")

var selected_slot = 0

func _ready():
	Global.inventory_updated.connect(_update_hotbar)
	_update_hotbar()

# Create the hotbar slots
func _update_hotbar():
	clear_hotbar_container()
	for i in range(Global.hotbar_size):
		var item = Global.inventory[i]
		var slot = Global.hotbar_slot_scene.instantiate()
		slot.set_slot_index(i)
		hotbar_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()
		
# Clear hotbar slots
func clear_hotbar_container():
	while hotbar_container.get_child_count() > 0:
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()
