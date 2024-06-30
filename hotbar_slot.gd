extends Control

@onready var icon = $HotbarContainer/ItemIcon
@onready var quantity_label = $HotbarContainer/ItemQuantity
@onready var details_panel = $DetailPanel
@onready var item_name = $DetailPanel/ItemName
@onready var item_type = $DetailPanel/ItemType
@onready var item_description = $DetailPanel/ItemDescription
@onready var usage_panel = $UsagePanel
@onready var item_button = $ItemButton
@onready var selector = $selector

var item = null
var slot_index = -1
var is_assigned = false
var currently_selected: int = 0

func set_empty():
	icon.texture = null
	quantity_label.text = ""

func set_slot_index(new_index):
	slot_index = new_index

func _on_item_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited():
	details_panel.visible = false
	
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
		
func _on_use_button_pressed():
	selector.visible = false
	if item != null and item["name"] != "":
		if Global.player_node:
			Global.player_node.highlight_item(item)
			
	else:
		print("player could not be found")

		
func _on_item_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if item != null:
				usage_panel.visible = !usage_panel.visible
