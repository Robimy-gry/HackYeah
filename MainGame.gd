extends Node2D

const PLAYER = 0
const BORDER = 1
const MAP_WIDTH = 25
const MAP_HEIGHT = 20
const POWERUP_TYPES = ["SPEED_UP", "LIFE", "TELEPORT", "SPEED_DOWN"]
var borders = []
var powerup
var player_body = []
var start_player_direction = Vector2(1,0)
var player_direction = start_player_direction
var teleport = false
var teleport_pos
var border_eaten
var player_lives = 3
var start_player_position = []
var game_over = false


func _ready():
	get_start_positions()
	powerup = place_powerup()
	draw_powerup()
	draw_player()
	draw_borders()


func get_start_positions():
	for element in $Elements.get_used_cells_by_id(0):
		start_player_position.push_front(element)
	player_body = start_player_position
	borders =$Elements.get_used_cells_by_id(1)

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
			powerup["type"] = randi() % POWERUP_TYPES.size()
			powerup["tile"] = powerup["type"] + 2
			print(POWERUP_TYPES[powerup["type"]], ": position = ({x}, {y})".format({"x": x, "y": y}))
			valid_point = true
	return powerup


func draw_borders():
	for border in borders:
		$Elements.set_cell(border.x, border.y, BORDER)

func draw_powerup():
	$Elements.set_cell(powerup["position"].x, powerup["position"].y, powerup["tile"])

func draw_player():
	for block in player_body:
		$Elements.set_cell(block.x, block.y, PLAYER)


func move_player():
	delete_tiles(PLAYER)
	var body_copy
	if border_eaten:
		body_copy = player_body.slice(0, player_body.size() - 1)
		border_eaten = false
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
	$Player.position = Vector2(16+(32*new_head.x), 16+(32*new_head.y))
	print($Player.position)
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
			border_eaten = true
		counter += 1
	for index in indexes:
		borders.remove(index)
		
func check_powerup_eaten():
	if powerup["position"] == player_body[0]:
		activate_powerup(powerup)
		powerup = place_powerup()


func activate_powerup(powerup):
	if POWERUP_TYPES[powerup["type"]] == "LIFE":
		player_lives += 1
		print("Current player lives: ", player_lives)
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


func check_game_over():
	var head = player_body[0]
	for block in player_body.slice(1, player_body.size() - 1):
		if block == head:
			reset()

func reset():
	player_lives -= 1
	player_body = start_player_position
	player_direction = start_player_direction
	if player_lives <= 0: game_over = true
	


func _on_PlayerMovementTimer_timeout() -> void:
	move_player()
	draw_borders()
	draw_powerup()
	draw_player()
	check_border_eaten()
	check_powerup_eaten()


func _on_PowerupTimer_timeout() -> void:
	$PlayerMovementTimer.wait_time = 0.2


func _process(delta):
	check_game_over()
