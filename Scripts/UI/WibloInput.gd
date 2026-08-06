@tool
class_name WibloInput
extends LineEdit


## Señales opcionales conservadas para mantener una interfaz
## similar a la versión anterior del componente.
signal value_changed(value: String)
signal submitted(value: String)


enum InputType {
	TEXT,
	EMAIL,
	PASSWORD,
	NUMBER,
	DECIMAL,
	PHONE,
	URL
}


@export_category("Contenido")

@export var placeholder: String = "Escribe aquí":
	set(value):
		placeholder = value
		_apply_visuals()


@export var input_type: InputType = InputType.TEXT:
	set(value):
		input_type = value
		_apply_visuals()


@export var show_clear_button: bool = false:
	set(value):
		show_clear_button = value
		_apply_visuals()


@export_category("Apariencia")

@export var theme_variation_name: StringName = &"AuthLineEdit":
	set(value):
		theme_variation_name = value
		_apply_visuals()


@export_range(60.0, 160.0, 1.0, "suffix:px")
var input_height: float = 90.0:
	set(value):
		input_height = value
		_apply_visuals()


@export_category("Comportamiento")

## Elimina espacios al comienzo y al final cuando se usa get_value().
## El texto original siempre puede obtenerse con get_raw_value().
@export var trim_value_edges: bool = true


func _ready() -> void:
	_connect_input_signals()
	_apply_visuals()


func _connect_input_signals() -> void:
	if not text_changed.is_connected(_on_text_changed):
		text_changed.connect(_on_text_changed)

	if not text_submitted.is_connected(_on_text_submitted):
		text_submitted.connect(_on_text_submitted)


func _apply_visuals() -> void:
	placeholder_text = placeholder
	custom_minimum_size.y = input_height
	theme_type_variation = theme_variation_name

	# Se restablecen primero las propiedades para evitar que queden
	# valores anteriores al cambiar el tipo desde el Inspector.
	secret = false
	clear_button_enabled = show_clear_button
	virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT

	match input_type:
		InputType.TEXT:
			virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT

		InputType.EMAIL:
			virtual_keyboard_type = (
				LineEdit.KEYBOARD_TYPE_EMAIL_ADDRESS
			)

		InputType.PASSWORD:
			virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PASSWORD
			secret = true

			# Se desactiva porque el botón de limpiar podría facilitar
			# borrar accidentalmente una contraseña.
			clear_button_enabled = false

		InputType.NUMBER:
			virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER

		InputType.DECIMAL:
			virtual_keyboard_type = (
				LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
			)

		InputType.PHONE:
			virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PHONE

		InputType.URL:
			virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_URL


## Devuelve el texto procesado para formularios.
func get_value() -> String:
	if trim_value_edges:
		return text.strip_edges()

	return text


## Devuelve exactamente lo escrito por el usuario.
func get_raw_value() -> String:
	return text


func set_value(value: String) -> void:
	text = value


func clear_value() -> void:
	clear()


func set_input_editable(value: bool) -> void:
	editable = value


func focus_input() -> void:
	grab_focus()


func _on_text_changed(value: String) -> void:
	if Engine.is_editor_hint():
		return

	value_changed.emit(value)


func _on_text_submitted(value: String) -> void:
	if Engine.is_editor_hint():
		return

	submitted.emit(value)
