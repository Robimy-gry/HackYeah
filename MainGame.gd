extends Node2D

const PLAYER = 0
const BORDER = 1
var player_body = [Vector2(4,5), Vector2(3,5), Vector2(2,5)]
var player_direction = Vector2(1,0)


func _ready():
	draw_player()
	

func draw_player():
	for block in player_body:
		$Elements.set_cell(block.x, block.y, PLAYER)


func move_player():
	delete_tiles(PLAYER)
	var body_copy = player_body.slice(0, player_body.size() - 2)
	var new_head = body_copy[0] + player_direction
	body_copy.insert(0, new_head)
	player_body = body_copy


func delete_tiles(id):
	var cells = $Elements.get_used_cells_by_id(id)
	for cell in cells:
		$Elements.set_cell(cell.x, cell.y,-1)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_down"): player_direction = Vector2(0,1)
	if Input.is_action_just_pressed("ui_up"): player_direction = Vector2(0,-1)
	if Input.is_action_just_pressed("ui_left"): player_direction = Vector2(-1,0)
	if Input.is_action_just_pressed("ui_right"): player_direction = Vector2(1,0)

func _on_PlayerMovementTimer_timeout() -> void:
	move_player()
	draw_player()
