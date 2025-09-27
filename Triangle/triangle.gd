extends RigidBody2D

var is_shot: bool = false
var is_highlighted: bool = false
var highlight_material: ShaderMaterial = null

# Enable contact monitoring so that `body_entered` signal is emitted.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10  # any positive value enables the signal
	# Cache sprite reference for highlighting
	_sprite = get_node("Sprite2D")
	_create_highlight_material()

func shoot(direction: Vector2, force: float, lifetime: float) -> void:
	if is_shot:
		return
	is_shot = true
	# Apply an instantaneous impulse in the desired direction
	apply_impulse(direction.normalized() * force)
	# Schedule this triangle for deletion after its lifetime
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _on_body_entered(body: Node) -> void:
	if body.has_method("onHit"):
		body.onHit()
		print("Collided")

var _sprite: Sprite2D

func _create_highlight_material() -> void:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float hue_shift : hint_range(-1.0, 1.0) = 0.6; // cycles 0-1

vec3 rgb2hsv(vec3 c){
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c){
    vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

void fragment(){
    vec4 tex = texture(TEXTURE, UV);
    vec3 hsv = rgb2hsv(tex.rgb);
    hsv.x = fract(hsv.x + hue_shift);
    vec3 rgb = hsv2rgb(hsv);
    COLOR = vec4(rgb, tex.a) * COLOR;
}
"""
	highlight_material = ShaderMaterial.new()
	highlight_material.shader = shader

func set_highlight(enable: bool) -> void:
	if enable == is_highlighted:
		return
	is_highlighted = enable
	if _sprite:
		_sprite.material = highlight_material if enable else null
