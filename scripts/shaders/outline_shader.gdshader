shader_type spatial;

render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 1.0) = 0.025;

void vertex() {
	VERTEX += (COLOR.rgb * 2.0 - 1.0) * outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
