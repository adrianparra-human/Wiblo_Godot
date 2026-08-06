extends Control

# Escena que se abrirá cuando termine o se salte el video.
@export_file("*.tscn")
var next_scene: String = "res://Escenas/Login.tscn"

# Permite saltar la introducción tocando la pantalla.
@export var allow_skip: bool = false

# Evita que el toque usado para abrir la aplicación
# salte inmediatamente el video.
@export var minimum_skip_time: float = 0.5

@onready var video_player: VideoStreamPlayer = (
	$AspectRatioContainer/VideoStreamPlayer
)

var elapsed_time: float = 0.0
var changing_scene: bool = false


func _ready() -> void:
	# Conecta automáticamente la señal que se emite
	# cuando el video termina.
	video_player.finished.connect(_go_to_next_scene)

	# Inicia la reproducción.
	video_player.play()


func _process(delta: float) -> void:
	elapsed_time += delta


func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip:
		return

	if changing_scene:
		return

	if elapsed_time < minimum_skip_time:
		return

	# Toque en Android o iOS.
	if event is InputEventScreenTouch:
		if event.pressed:
			_go_to_next_scene()
			get_viewport().set_input_as_handled()
			return

	# Clic del mouse para probar desde el computador.
	if event is InputEventMouseButton:
		if event.pressed:
			_go_to_next_scene()
			get_viewport().set_input_as_handled()
			return

	# Enter, espacio o Escape para probar desde el computador.
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_ESCAPE]:
				_go_to_next_scene()
				get_viewport().set_input_as_handled()


func _go_to_next_scene() -> void:
	# Evita cargar dos veces la escena si el usuario toca
	# justo cuando termina el video.
	if changing_scene:
		return

	changing_scene = true
	video_player.stop()

	if next_scene.is_empty():
		push_error("No se configuró la escena siguiente.")
		return

	var error: Error = get_tree().change_scene_to_file(next_scene)

	if error != OK:
		changing_scene = false
		push_error(
			"No se pudo cargar la escena: %s. Código de error: %s"
			% [next_scene, error]
		)
