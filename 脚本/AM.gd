gdscript
extends Node

class_name AnimationManager

var animations = {}

func add_animation(name, animation):
    animations[name] = animation

func play_animation(name, node):
    if name in animations:
        animations[name].play(node)

class BaseAnimation:
    var duration = 1.0
    var loop = 0
    var reverse = false

    func _process_animation(node, delta):
        pass

    func play(node):
        node.add_child(self)
        self.start()

    func start():
        self._process_animation(self, 0.0)

    func _process(delta):
        self._process_animation(self, delta)
        duration -= delta
        if duration <= 0:
            if reverse:
                self.reverse_animation()
            elif loop == 0:
                self.start()
            elif loop > 1:
                loop -= 1
                self.start()
            else:
                self.finish()

    func reverse_animation():
        duration = duration
        self.start()

    func finish():
        self.queue_free()

class MoveTo(BaseAnimation):
    var target_position = Vector2(0, 0)
    var initial_position = Vector2(0, 0)
    var velocity = Vector2(0, 0)

    func init(initial_position, target_position, duration):
        self.initial_position = initial_position
        self.target_position = target_position
        self.duration = duration

    func _process_animation(node, delta):
        var direction = (target_position - initial_position).normalized()
        velocity = direction * (target_position.distance_to(initial_position) / duration)
        node.translation += velocity * delta