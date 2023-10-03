extends Node2D

var viewport : Viewport
var move : Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport = get_viewport()

func test():
	print("camera test")
	print(viewport.canvas_transform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var transform = viewport.canvas_transform
	move.x += 1
	transform.translated(move)
	viewport.set_canvas_transform(transform)
