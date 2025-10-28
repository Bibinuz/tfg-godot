shader_type spatial;

render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 0.1) = 0.05;

void vertex() {
    // Expand vertices along normals in view space
    VERTEX += NORMAL * outline_thickness;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;

}