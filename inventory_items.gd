extends Control

class_name InventorySlot

@onready var icon = $InventoryContainer/ItemIcon
@onready var quantity_label = $InventoryContainer/ItemQuantity
@onready var details_panel = $DetailPanel
@onready var item_name = $DetailPanel/ItemName
@onready var item_type = $DetailPanel/ItemType
@onready var item_description = $DetailPanel/ItemDescription
@onready var usage_panel = $UsagePanel
@onready var item_button = $ItemButton

var item_in_hand
var initialpos: Vector2
var offset: Vector2

signal drag_start(slot)
signal drag_end()

var item = null
var slot_index = -1
var is_assigned = false

func set_slot_index(new_index):
	slot_index = new_index

func _on_item_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited():
	details_panel.visible = false

func set_empty():
	icon.texture = null
	quantity_label.text = ""
	
func set_item(new_item):
	item = new_item
	icon.texture = new_item["texture"]
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	if item["description"] != "":
		item_description.text = str("", item["description"])
	else:
		item_description.text = ""
		
func _on_drop_button_pressed():
	if item != null:
		var drop_position = Global.player_node.global_position
		var drop_offset = Vector2(0, 50)
		drop_offset = drop_offset.rotated(Global.player_node.rotation)
		Global.drop_item(item, drop_position + drop_offset)
		Global.remove_item(item["type"], item["description"])
		usage_panel.visible = false
		
func _on_item_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if item != null:
				usage_panel.visible = !usage_panel.visible
				
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				item_in_hand = true
				quantity_label.visible = false
				drag_start.emit(self)
			else:
				drag_end.emit()
				quantity_label.visible = true
				item_in_hand = false
	
func _physics_process(delta):
	if item_in_hand == true:
		icon.global_position = get_global_mouse_position()
	if item_in_hand == false:
		offset = Vector2(30,30)
		icon.global_position = item_button.global_position + offset
