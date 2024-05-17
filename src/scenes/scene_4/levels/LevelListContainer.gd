extends VBoxContainer

var niveles = ["Nivel 1", "Nivel 2", "Nivel 3", "Nivel 4"] # Lista de nombres de niveles

func _ready():
	# Itera sobre la lista de niveles y crea un nodo de texto para cada uno
	for nivel_nombre in niveles:
		var nodo_texto = Label.new()
		nodo_texto.text = nivel_nombre
		add_child(nodo_texto) # Agrega el nodo de texto al contenedor
