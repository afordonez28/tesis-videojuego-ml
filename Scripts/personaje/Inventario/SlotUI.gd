class_name SlotUI
extends Panel

signal slot_clicked(slot_ui)
signal slot_right_clicked(slot_ui)

@onready var icon: TextureRect = $Icon
@onready var amount_label: Label = $AmountLabel

var array_name: String = ""
var slot_index: int = 0
var slot_data = null  # {"item": ItemData, "amount": int} o null

# Para drag & drop
static var dragged_slot: SlotUI = null

func update_display():
	if slot_data == null:
		icon.texture = null
		amount_label.text = ""
	else:
		icon.texture = slot_data["item"].icon
		amount_label.text = str(slot_data["amount"]) if slot_data["amount"] > 1 else ""

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(self)

# --- Drag & Drop ---
func _get_drag_data(_pos):
	if slot_data == null:
		return null
	dragged_slot = self
	var preview = TextureRect.new()
	preview.texture = slot_data["item"].icon
	preview.size = Vector2(48, 48)
	set_drag_preview(preview)
	return {"from_slot": self}

func _can_drop_data(_pos, data) -> bool:
	return data is Dictionary and data.has("from_slot")

func _drop_data(_pos, data):
	var from: SlotUI = data["from_slot"]
	InventoryManager.swap_slots(
		from.array_name, from.slot_index,
		array_name, slot_index
	)
