extends Node3D

var is_mouse_inside = false

@export var gameScene: PackedScene
@export var viewport: SubViewport
@export var viewportquad: MeshInstance3D
@export var spawnDisplace: Vector3

var gameChild: Node3D

func _unhandled_input(event: InputEvent) -> void:
	viewport.push_input(event, true)

func _ready() -> void:
	gameChild = gameScene.instantiate()
	#viewport = $SubViewport
	#var viewportquad: MeshInstance3D = $ViewportQuad
	
	set_pause(true)
	
	viewport.add_child(gameChild)
	gameChild.position = position + spawnDisplace
	
	var material = StandardMaterial3D.new()
	material.albedo_texture = viewport.get_texture()
	
	viewportquad.material_override = material
	#print(viewport.get_texture())
	#print(viewport)
	#print(viewportquad)

func set_pause(pause: bool):
	if pause:
		gameChild.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		gameChild.process_mode = Node.PROCESS_MODE_INHERIT
