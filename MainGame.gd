extends Node2D

const PLAYER = 0
const BORDER = 1
const POWERUP = 2
const MAP_WIDTH = 25
const MAP_HEIGHT = 20
const POWERUP_TYPES = ["LIFE", "SPEED_UP", "SPEED_DOWN", "TELEPORT"]
var borders = [
	Vector2(4,10), Vector2(5,10), Vector2(6,10), 
	Vector2(4,11), Vector2(4,12), Vector2(3,12), 
	Vector2(2,12), Vector2(1,12), Vector2(0,12)]
var powerup
var player_body = [Vector2(4,5), Vector2(3,5), Vector2(2,5)]
var player_direction = Vector2(1,0)
var add_life = false
var teleport = false
var teleport_pos


func _ready():
	powerup = place_powerup()
	draw_powerup()
	draw_player()
	draw_borders()


func place_powerup():
	var valid_point = false
	var x
	var y
	var powerup = {}
	while (not valid_point):
		randomize()
		x = randi() % MAP_WIDTH
		y = randi() % MAP_HEIGHT
		if $Elements.get_cell(x,y) == -1:
			powerup["position"] = Vector2(x,y)
			powerup["type"] = randi() % len(POWERUP_TYPES)
			print(POWERUP_TYPES[powerup["type"]], ": position = ({x}, {y})".format({"x": x, "y": y}))
			valid_point = true
	return powerup


func draw_borders():
	for border in borders:
		$Elements.set_cell(border.x, border.y, BORDER)

func draw_powerup():
	$Elements.set_cell(powerup["position"].x, powerup["position"].y, POWERUP)

func draw_player():
	for block in player_body:
		$Elements.set_cell(block.x, block.y, PLAYER)


func move_player():
	delete_tiles(PLAYER)
	var body_copy
	if add_life:
		body_copy = player_body.slice(0, player_body.size() - 1)
		add_life = false
	else:
		body_copy = player_body.slice(0, player_body.size() - 2)
	var new_head = body_copy[0] + player_direction
	if new_head.x < 0: new_head.x = MAP_WIDTH - 1
	if new_head.x >= MAP_WIDTH: new_head.x = 0
	if new_head.y < 0: new_head.y = MAP_HEIGHT - 1
	if new_head.y >= MAP_HEIGHT: new_head.y = 0
	if teleport:
		new_head = teleport_pos
		teleport = false
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


func check_border_eaten():
	var counter = 0
	var indexes = []
	for border in borders:
		if border == player_body[0]:
			indexes.push_front(counter)
		counter += 1
	for index in indexes:
		borders.remove(index)
		
func check_powerup_eaten():
	if powerup["position"] == player_body[0]:
		activate_powerup(powerup)
		powerup = place_powerup()


func activate_powerup(powerup):
	if POWERUP_TYPES[powerup["type"]] == "LIFE":
		add_life = true
	elif POWERUP_TYPES[powerup["type"]] in ["SPEED_UP", "SPEED_DOWN"]:
		$PowerupTimer.stop()
		$PowerupTimer.stop()
		if POWERUP_TYPES[powerup["type"]] == "SPEED_UP":
			$PlayerMovementTimer.wait_time = 0.1
		if POWERUP_TYPES[powerup["type"]] == "SPEED_DOWN":
			$PlayerMovementTimer.wait_time = 0.4
		$PowerupTimer.start()
	elif POWERUP_TYPES[powerup["type"]] == "TELEPORT":
		teleport_pos = teleport_player()
		
func teleport_player():
	var valid_point = false
	var x
	var y
	while(not valid_point):
		randomize()
		x = randi() % MAP_WIDTH
		y = randi() % MAP_HEIGHT
		if $Elements.get_cell(x,y) == -1:
			valid_point = true
			teleport = true
	return Vector2(x,y)
	


func _on_PlayerMovementTimer_timeout() -> void:
	move_player()
	draw_borders()
	draw_powerup()
	draw_player()
	check_border_eaten()
	check_powerup_eaten()


func _on_PowerupTimer_timeout() -> void:
	$PlayerMovementTimer.wait_time = 0.2
