shader_type canvas_item;

uniform float threshold_water : hint_range(0.0, 1.0) = 0.6;
uniform float threshold_border : hint_range(0.0, 1.0) = 0.4;
uniform vec4 water_color : source_color = vec4(0.0, 0.46, 1.0, 1.0);
uniform vec4 border_color : source_color = vec4(0.45, 0.86, 1.0, 1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float a = color.a;
	
	if (a >= threshold_water) {
		COLOR = water_color;
	} else if (a >= threshold_border) {
		COLOR = border_color;
	} else {
		COLOR = vec4(0.0);
	}
}
