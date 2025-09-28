shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float radius : hint_range(0.0, 2.0) = 1.0;
uniform float softness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.4, 0.0, 0.0, 0.6); // static dark red

void fragment() {
    vec2 uv = (UV - 0.5) * 2.0;       
    float dist = length(uv);          
    float mask = smoothstep(radius - softness, radius, dist);
    
    COLOR = vec4(vignette_color.rgb, mask * vignette_color.a);
}
