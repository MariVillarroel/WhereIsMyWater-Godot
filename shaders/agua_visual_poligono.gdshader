shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.0, 0.46, 1.0, 1.0);
uniform float wave_strength : hint_range(0.0, 0.2, 0.001) = 0.035;
uniform float wave_scale : hint_range(1.0, 80.0, 0.1) = 22.0;
uniform float wave_speed : hint_range(0.0, 8.0, 0.1) = 2.2;

void fragment() {
	float wave = sin((UV.x + UV.y) * wave_scale + TIME * wave_speed) * wave_strength;
	vec4 source = COLOR;
	vec3 color = mix(source.rgb, tint_color.rgb, 0.55 + wave);
	COLOR = vec4(color, source.a * tint_color.a);
}
