shader_type canvas_item;

uniform vec4 water_color : source_color = vec4(0.12, 0.68, 0.95, 0.88);
uniform float threshold : hint_range(0.0, 1.0, 0.01) = 0.08;
uniform float smoothness : hint_range(0.001, 0.5, 0.001) = 0.08;
uniform float edge_softness : hint_range(0.0, 1.0, 0.01) = 0.02;
uniform float alpha_multiplier : hint_range(0.0, 2.0, 0.01) = 1.2;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float blue_dominance = max(source.b - max(source.r, source.g) * 0.82, 0.0);
	float cyan_dominance = max(source.g - source.r * 0.65, 0.0);
	float field = blue_dominance * cyan_dominance * source.a * alpha_multiplier * 4.0;
	float body = smoothstep(threshold, threshold + smoothness, field);
	float edge_start = max(threshold - edge_softness, 0.001);
	float edge = smoothstep(edge_start, threshold, field);
	float final_alpha = max(body, edge * 0.55) * water_color.a;

	if (final_alpha <= 0.01) {
		discard;
	}

	COLOR = vec4(water_color.rgb, final_alpha);
}
