shader_type spatial;

// ===== VARYINGS =====
varying vec3 world_pos;
varying vec3 world_normal;

// ===== PARAMÈTRES =====
uniform float min_height = 0.0;
uniform float max_height = 20.0;

// Couleurs
uniform vec4 grass_color : source_color = vec4(0.2, 0.7, 0.3, 1.0);
uniform vec4 rock_color  : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 snow_color  : source_color = vec4(0.95, 0.95, 0.95, 1.0);

// Réglages
uniform float snow_start = 0.7;       // altitude (0–1)
uniform float blend_smooth = 0.1;     // douceur des transitions
uniform float slope_threshold = 0.6;  // seuil pente (0 = vertical, 1 = plat)

// ===== VERTEX =====
void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// ===== FRAGMENT =====
void fragment() {
    float h = world_pos.y;

    // Normalisation hauteur
    float height_ratio = clamp((h - min_height) / (max_height - min_height), 0.0, 1.0);

    // Calcul pente (1 = plat, 0 = vertical)
    float slope = dot(world_normal, vec3(0.0, 1.0, 0.0));

    // --- HERBE vs ROCHE ---
    float slope_mask = smoothstep(slope_threshold, slope_threshold + blend_smooth, slope);
    vec3 base_color = mix(rock_color.rgb, grass_color.rgb, slope_mask);

    // --- NEIGE ---
    float snow_mask = smoothstep(snow_start, snow_start + blend_smooth, height_ratio);
    vec3 final_color = mix(base_color, snow_color.rgb, snow_mask);

    ALBEDO = final_color;
}