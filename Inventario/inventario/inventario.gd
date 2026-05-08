# Clase de Inventario
# Esta clase extiende 'Resource' para crear un objeto de datos de inventario.
# Sirve para gestionar y almacenar los objetos de un jugador.
extends Resource

# nombre de la clase del inventario
class_name Mochila

#variable para guardar los items
@export var objetos:Dictionary = {}

# funcion para agregar los items a la variable objetos
# Retorna 'true' si el ítem se agregó con éxito.
func agregar_item(item: Item) -> bool:
	# La clave para buscar el ítem en el diccionario será su nombre.
	var clave = item.nombre 
	
	# 1. Comprueba si el ítem ya existe en la mochila.
	if objetos.has(clave):
		var item_en_mochila = objetos[clave]
		# 2. Si el ítem es apilable y su cantidad actual es menor que la cantidad máxima,
		# incrementa la cantidad en uno y retorna 'true'.
		if item_en_mochila.apilable and item_en_mochila.cantidad < item_en_mochila.max_cantidad:
			item_en_mochila.cantidad += 1
			return true
	
	# 3. Crea una nueva instancia del ítem para evitar modificar el recurso original.
	var nueva_instancia_item = item.duplicate()
	var clave_nueva = clave
	
	# 4. Si el nuevo ítem no es apilable o si su nombre ya existe como clave,
	# se le asigna una clave única añadiendo un número aleatorio al final.
	if not nueva_instancia_item.apilable or objetos.has(clave_nueva):
		clave_nueva += "_" + str(randi())
	
	# 5. Añade la nueva instancia del ítem al diccionario 'objetos' con la clave final.
	objetos[clave_nueva] = nueva_instancia_item
	return true
	
