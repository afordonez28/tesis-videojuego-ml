extends Node

# ─────────────────────────────────────────
# SEÑALES
# ─────────────────────────────────────────
signal inventory_changed

# ─────────────────────────────────────────
# CONSTANTES
# ─────────────────────────────────────────
const INVENTORY_SIZE = 30
const HOTBAR_SIZE = 9

# ─────────────────────────────────────────
# DATOS DE SLOTS
# Cada slot es: {"item": ItemData, "amount": int} o null
# ─────────────────────────────────────────
var inventory: Array = []          # 30 slots del inventario grande
var hotbar: Array = []             # 9 slots del hotbar
var armor_slots: Array = []        # 3 slots: [cabeza, pecho, piernas]
var complement_slot = null         # 1 slot de complemento
var craft_input: Array = []        # 2 slots de entrada de crafteo
var craft_output = null            # 1 slot de salida de crafteo

# ─────────────────────────────────────────
# RECETAS DE CRAFTEO
# Clave: Array con los IDs de los dos ítems (ordenados)
# Valor: ItemData del resultado
# Agrega tus recetas aquí cuando tengas más ítems
# ─────────────────────────────────────────
var recipes: Dictionary = {
	# Ejemplo (descomenta cuando tengas el recurso):
	# ["madera", "piedra"]: preload("res://Resources/hacha.tres"),
}

# ─────────────────────────────────────────
# INICIALIZACIÓN
# ─────────────────────────────────────────
func _ready():
	inventory.resize(INVENTORY_SIZE)
	hotbar.resize(HOTBAR_SIZE)
	armor_slots.resize(3)
	craft_input.resize(2)

	# Llenar todo con null
	for i in INVENTORY_SIZE:
		inventory[i] = null
	for i in HOTBAR_SIZE:
		hotbar[i] = null
	for i in 3:
		armor_slots[i] = null
	for i in 2:
		craft_input[i] = null

# ─────────────────────────────────────────
# AGREGAR ÍTEM AL INVENTARIO
# Intenta apilar primero, luego busca slot vacío
# Primero llena el hotbar, luego el inventario grande
# Retorna true si tuvo éxito, false si está lleno
# ─────────────────────────────────────────
func add_item(item_data: ItemData, amount: int = 1) -> bool:
	# 1. Intentar apilar en slots existentes del mismo ítem
	for arr in [hotbar, inventory]:
		for i in arr.size():
			var slot = arr[i]
			if slot != null and slot["item"] == item_data and item_data.stackable:
				if slot["amount"] < item_data.max_stack:
					slot["amount"] += amount
					inventory_changed.emit()
					return true

	# 2. Buscar primer slot vacío
	for arr in [hotbar, inventory]:
		for i in arr.size():
			if arr[i] == null:
				arr[i] = {"item": item_data, "amount": amount}
				inventory_changed.emit()
				return true

	# 3. Inventario lleno
	print("Inventario lleno, no se pudo agregar: ", item_data.name)
	return false

# ─────────────────────────────────────────
# ELIMINAR ÍTEM EN POSICIÓN ESPECÍFICA
# ─────────────────────────────────────────
func remove_item_at(array_name: String, index: int):
	var arr = _get_array(array_name)
	if arr.size() > index:
		arr[index] = null
	inventory_changed.emit()

# ─────────────────────────────────────────
# INTERCAMBIAR DOS SLOTS (drag & drop)
# ─────────────────────────────────────────
func swap_slots(from_arr: String, from_idx: int, to_arr: String, to_idx: int):
	var a = _get_array(from_arr)
	var b = _get_array(to_arr)

	if a.size() <= from_idx or b.size() <= to_idx:
		push_error("swap_slots: índice fuera de rango")
		return

	var temp = a[from_idx]
	a[from_idx] = b[to_idx]
	b[to_idx] = temp

	inventory_changed.emit()

# ─────────────────────────────────────────
# OBTENER DATOS DE UN SLOT
# ─────────────────────────────────────────
func get_slot(array_name: String, index: int):
	var arr = _get_array(array_name)
	if arr.size() > index:
		return arr[index]
	return null

# ─────────────────────────────────────────
# CRAFTEO
# Revisa si los dos slots de entrada forman una receta válida
# Retorna true si se encontró receta y se generó el output
# ─────────────────────────────────────────
func try_craft() -> bool:
	# Verificar que los dos slots de entrada tengan ítems
	if craft_input[0] == null or craft_input[1] == null:
		craft_output = null
		inventory_changed.emit()
		return false

	# Crear clave con los IDs ordenados (el orden no importa)
	var key = [craft_input[0]["item"].id, craft_input[1]["item"].id]
	key.sort()

	if recipes.has(key):
		craft_output = {"item": recipes[key], "amount": 1}
		inventory_changed.emit()
		return true

	# No hay receta válida
	craft_output = null
	inventory_changed.emit()
	return false

# ─────────────────────────────────────────
# RECOGER RESULTADO DEL CRAFTEO
# Mueve el output al inventario y limpia los slots de crafteo
# ─────────────────────────────────────────
func collect_craft_result() -> bool:
	if craft_output == null:
		return false

	var success = add_item(craft_output["item"], craft_output["amount"])
	if success:
		craft_input[0] = null
		craft_input[1] = null
		craft_output = null
		inventory_changed.emit()
	return success

# ─────────────────────────────────────────
# HELPER INTERNO
# Retorna la referencia al array según el nombre
# ─────────────────────────────────────────
func _get_array(name: String) -> Array:
	match name:
		"hotbar":      return hotbar
		"inventory":   return inventory
		"armor":       return armor_slots
		"craft_input": return craft_input
		"craft_output":
			# craft_output es una variable suelta, no array
			# se maneja directamente, no por aquí
			push_warning("craft_output no es un array, manéjalo directamente")
			return []
		_:
			push_error("_get_array: nombre de array desconocido: " + name)
			return []

# ─────────────────────────────────────────
# DEBUG — imprime el estado del inventario en consola
# Llama InventoryManager.debug_print() cuando necesites revisar
# ─────────────────────────────────────────
func debug_print():
	print("=== HOTBAR ===")
	for i in hotbar.size():
		if hotbar[i] != null:
			print("  [%d] %s x%d" % [i, hotbar[i]["item"].name, hotbar[i]["amount"]])
		else:
			print("  [%d] vacío" % i)

	print("=== INVENTARIO ===")
	for i in inventory.size():
		if inventory[i] != null:
			print("  [%d] %s x%d" % [i, inventory[i]["item"].name, inventory[i]["amount"]])

	print("=== ARMADURA ===")
	var armor_names = ["Cabeza", "Pecho", "Piernas"]
	for i in armor_slots.size():
		if armor_slots[i] != null:
			print("  %s: %s" % [armor_names[i], armor_slots[i]["item"].name])
		else:
			print("  %s: vacío" % armor_names[i])

	print("=== CRAFTEO ===")
	for i in craft_input.size():
		if craft_input[i] != null:
			print("  Input[%d]: %s" % [i, craft_input[i]["item"].name])
	if craft_output != null:
		print("  Output: %s" % craft_output["item"].name)
