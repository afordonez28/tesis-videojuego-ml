extends CanvasLayer

# -----------------------
# Variables de nodos
# -----------------------
var big_inventory
var inventory_grid
var hotbar_grid
var armor_slots_nodes = []
var complement_node
var craft_in = []
var craft_out

var slot_scene = preload("res://scenes/Inventario/SlotUI.tscn")
var is_open: bool = false

# -----------------------
# Ready
# -----------------------
func _ready():
	# Asignar nodos según la estructura
	big_inventory = $Control/TextureRect/BigInventory 
	inventory_grid = $Control/TextureRect/BigInventory/inventory_grid  
	hotbar_grid = $Control/TextureRect/HotbarContainer/hotbar_grid 

	armor_slots_nodes = [
		$Control/TextureRect/BigInventory/ArmorPanel/Casco, 
		$Control/TextureRect/BigInventory/ArmorPanel/Peto,
		$Control/TextureRect/BigInventory/ArmorPanel/Botas,
	]
	complement_node = $Control/TextureRect/BigInventory/ArmorPanel/Accesorio

	craft_in = [
		$Control/TextureRect/BigInventory/CraftPanel/CraftIn0,
		$Control/TextureRect/BigInventory/CraftPanel/CraftIn1,
	]
	craft_out = $Control/TextureRect/BigInventory/CraftPanel/CraftOut

	# Debug: verificar que todos los nodos se encontraron
	print("BigInventory: ", big_inventory)
	print("Inventory Grid: ", inventory_grid)
	print("Hotbar Grid: ", hotbar_grid)
	print("Armor Slots: ", armor_slots_nodes)
	print("Complement Node: ", complement_node)
	print("Craft In: ", craft_in)
	print("Craft Out: ", craft_out)

	# Inicialización
	big_inventory.visible = false
	_build_hotbar()
	_build_inventory()
	_setup_special_slots()
	InventoryManager.inventory_changed.connect(_refresh_all)

# -----------------------
# Input
# -----------------------
func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	is_open = !is_open
	big_inventory.visible = is_open
	get_tree().paused = is_open  # Pausar juego opcional

# -----------------------
# Construir Hotbar
# -----------------------
func _build_hotbar():
	for i in InventoryManager.HOTBAR_SIZE:
		var slot: SlotUI = slot_scene.instantiate()
		slot.array_name = "hotbar"
		slot.slot_index = i
		hotbar_grid.add_child(slot)

# -----------------------
# Construir Inventario
# -----------------------
func _build_inventory():
	inventory_grid.columns = 10
	for i in InventoryManager.INVENTORY_SIZE:
		var slot: SlotUI = slot_scene.instantiate()
		slot.array_name = "inventory"
		slot.slot_index = i
		inventory_grid.add_child(slot)

# -----------------------
# Slots especiales (armadura, craft)
# -----------------------
func _setup_special_slots():
	for i in 3:
		armor_slots_nodes[i].array_name = "armor"
		armor_slots_nodes[i].slot_index = i

	complement_node.array_name = "complement"
	complement_node.slot_index = 0

	for i in 2:
		craft_in[i].array_name = "craft_input"
		craft_in[i].slot_index = i

	craft_out.array_name = "craft_output"
	craft_out.slot_index = 0

# -----------------------
# Actualizar todo
# -----------------------
func _refresh_all():
	# Hotbar
	var hotbar_slots = hotbar_grid.get_children()
	for i in hotbar_slots.size():
		hotbar_slots[i].slot_data = InventoryManager.hotbar[i]
		hotbar_slots[i].update_display()

	# Inventario
	var inv_slots = inventory_grid.get_children()
	for i in inv_slots.size():
		inv_slots[i].slot_data = InventoryManager.inventory[i]
		inv_slots[i].update_display()

	# Armadura
	for i in 3:
		armor_slots_nodes[i].slot_data = InventoryManager.armor_slots[i]
		armor_slots_nodes[i].update_display()
