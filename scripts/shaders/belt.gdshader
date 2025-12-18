shader_type spatial;

uniform sampler2D belt_texture : source_color, filter_linear_mipmap_anisotropic;
uniform float tiling_factor = 1.0;

void vertex() {
    // 1. Get the global scale on the X axis
    float scale_x = length(MODEL_MATRIX[0].xyz);

    // 2. Check the Normal vector.
    // If NORMAL.x is close to 1 or -1, we are looking at the Left/Right ends.
    // We only want to stretch if we are NOT on the ends.
    float is_end_cap = step(0.5, abs(NORMAL.x));

    // 3. Apply logic:
    // If it's an end cap (is_end_cap = 1.0), use standard UV (scale 1.0).
    // If it's the body (is_end_cap = 0.0), multiply by the scale.
    float final_scale = mix(scale_x, 1.0, is_end_cap);
    
    UV.x *= final_scale * tiling_factor;
}

void fragment() {
    vec4 albedo_tex = texture(belt_texture, UV);
    ALBEDO = albedo_tex.rgb;
    
    // Optional: Make it look like plastic/rubber
    ROUGHNESS = 0.6;
    SPECULAR = 0.2;
}