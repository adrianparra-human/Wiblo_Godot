@tool
class_name WibloButton
extends Button


enum ButtonStyle {
	PRIMARY,
	SECONDARY,
	SOCIAL,
	LINK
}


@export_category("Contenido")

@export var button_text: String = "Botón":
	set(value):
		button_text = value
		text = value


@export var button_icon: Texture2D:
	set(value):
		button_icon = value
		icon = value


@export_category("Apariencia")

@export var button_style: ButtonStyle = ButtonStyle.PRIMARY:
	set(value):
		button_style = value
		_apply_style()


@export_range(48.0, 180.0, 1.0, "suffix:px")
var minimum_height: float = 105.0:
	set(value):
		minimum_height = value
		custom_minimum_size.y = value


@export var expand_button_icon: bool = true:
	set(value):
		expand_button_icon = value
		expand_icon = value


func _ready() -> void:
	_refresh_button()


func _refresh_button() -> void:
	text = button_text
	icon = button_icon
	expand_icon = expand_button_icon
	custom_minimum_size.y = minimum_height
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	_apply_style()


func _apply_style() -> void:
	match button_style:
		ButtonStyle.PRIMARY:
			theme_type_variation = &"PrimaryButton"
			flat = false

		ButtonStyle.SECONDARY:
			theme_type_variation = &"SecondaryButton"
			flat = false

		ButtonStyle.SOCIAL:
			theme_type_variation = &"SocialButton"
			flat = false

		ButtonStyle.LINK:
			theme_type_variation = &"LinkButton"
			flat = true
