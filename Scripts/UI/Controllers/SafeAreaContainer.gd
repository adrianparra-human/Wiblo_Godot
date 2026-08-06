extends MarginContainer

## Espacio adicional dentro del área segura.
## Orden: izquierda, arriba, derecha, abajo.
@export var extra_padding: Vector4 = Vector4(32.0, 24.0, 32.0, 24.0)

## Permite simular un notch cuando se prueba desde Windows o macOS.
@export var enable_desktop_preview: bool = false

## Márgenes simulados para probar desde el computador.
## Orden: izquierda, arriba, derecha, abajo.
@export var desktop_preview_margins: Vector4 = Vector4(
	0.0,
	100.0,
	0.0,
	50.0
)


func _ready() -> void:
	# Se actualiza cuando cambia el tamaño de la ventana o viewport.
	get_viewport().size_changed.connect(_request_safe_area_update)

	# Se actualiza si el teléfono cambia de orientación.
	DisplayServer.orientation_changed.connect(
		_on_orientation_changed
	)

	# Espera a que Godot termine de calcular el tamaño inicial.
	call_deferred("_update_safe_area")


func _request_safe_area_update() -> void:
	call_deferred("_update_safe_area")


func _on_orientation_changed(_orientation: int) -> void:
	call_deferred("_update_safe_area")


func _update_safe_area() -> void:
	var left_margin: float = extra_padding.x
	var top_margin: float = extra_padding.y
	var right_margin: float = extra_padding.z
	var bottom_margin: float = extra_padding.w

	var platform_name: String = OS.get_name()
	var is_mobile: bool = platform_name == "Android" or platform_name == "iOS"

	if is_mobile:
		var safe_area_pixels: Rect2i = DisplayServer.get_display_safe_area()

		if safe_area_pixels.size.x > 0 and safe_area_pixels.size.y > 0:
			var viewport: Viewport = get_viewport()
			var visible_rect: Rect2 = viewport.get_visible_rect()

			# DisplayServer devuelve coordenadas físicas de pantalla.
			# Esta transformación las convierte al sistema de coordenadas
			# utilizado por la interfaz de Godot.
			var screen_to_viewport: Transform2D = (
				viewport.get_screen_transform().affine_inverse()
			)

			var safe_start_pixels := Vector2(
				safe_area_pixels.position.x,
				safe_area_pixels.position.y
			)

			var safe_end_pixels := Vector2(
				safe_area_pixels.position.x + safe_area_pixels.size.x,
				safe_area_pixels.position.y + safe_area_pixels.size.y
			)

			var safe_start: Vector2 = screen_to_viewport * safe_start_pixels
			var safe_end: Vector2 = screen_to_viewport * safe_end_pixels

			var visible_left: float = visible_rect.position.x
			var visible_top: float = visible_rect.position.y
			var visible_right: float = (
				visible_rect.position.x + visible_rect.size.x
			)
			var visible_bottom: float = (
				visible_rect.position.y + visible_rect.size.y
			)

			left_margin += maxf(
				0.0,
				safe_start.x - visible_left
			)

			top_margin += maxf(
				0.0,
				safe_start.y - visible_top
			)

			right_margin += maxf(
				0.0,
				visible_right - safe_end.x
			)

			bottom_margin += maxf(
				0.0,
				visible_bottom - safe_end.y
			)

	elif enable_desktop_preview:
		left_margin += desktop_preview_margins.x
		top_margin += desktop_preview_margins.y
		right_margin += desktop_preview_margins.z
		bottom_margin += desktop_preview_margins.w

	add_theme_constant_override(
		"margin_left",
		int(ceil(left_margin))
	)

	add_theme_constant_override(
		"margin_top",
		int(ceil(top_margin))
	)

	add_theme_constant_override(
		"margin_right",
		int(ceil(right_margin))
	)

	add_theme_constant_override(
		"margin_bottom",
		int(ceil(bottom_margin))
	)
