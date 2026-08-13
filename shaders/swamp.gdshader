shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.15, 0.18, 0.08, 1.0);
uniform vec4 murk_color : source_color = vec4(0.05, 0.08, 0.03, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.3, 0.32, 0.15, 1.0);
uniform vec4 foam_color : source_color = vec4(0.55, 0.55, 0.45, 1.0);
uniform vec4 scum_color : source_color = vec4(0.2, 0.35, 0.1, 1.0);
uniform sampler2D noise_tex;
uniform sampler2D noise_tex_large;
uniform float noise_tiling = 0.1;
uniform float wave_speed = 0.05;
uniform float wave_strength = 0.02;
uniform float roughness_val = 0.6;
uniform float depth_fade_distance = 1.5;
uniform float refraction_strength = 0.03;
uniform float foam_band_width = 0.15;
uniform float foam_noise_scale = 8.0;
uniform float scum_threshold = 0.4;
uniform float scum_density = 0.5;
uniform float scum_scroll_speed = 0.01;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_tex : hint_depth_texture, filter_linear_mipmap;

// --- Fondu des bords du mesh ---
uniform float edge_fade_width : hint_range(0.0, 0.5) = 0.08;

varying vec3 world_pos;

void vertex() {
    // Ici VERTEX est bien en espace LOCAL, donc MODEL_MATRIX est correct
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // On utilise le varying calculé dans vertex(), stable peu importe la caméra
    vec2 world_uv = world_pos.xz * noise_tiling;
    vec2 scroll = world_uv + vec2(TIME * wave_speed, TIME * wave_speed * 0.5);
    float noise = texture(noise_tex, scroll).r;
    vec3 n = NORMAL;
    n.xz += (noise - 0.5) * wave_strength;
    NORMAL = normalize(n);

    // --- Profondeur du fond ---
    float depth_raw = texture(depth_tex, SCREEN_UV).r;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;
    float scene_depth = -view_pos.z;
    float water_depth = -VERTEX.z; // ici VERTEX (espace vue) est correct pour comparer des profondeurs caméra
    float depth_diff = clamp((scene_depth - water_depth) / depth_fade_distance, 0.0, 1.0);

    // --- Réfraction ---
    vec2 refract_offset = n.xz * refraction_strength * depth_diff;
    vec3 refracted = texture(screen_tex, SCREEN_UV + refract_offset).rgb;

    // --- Couleur d'eau de base ---
    vec3 water_tint = mix(shallow_color.rgb, mix(water_color.rgb, murk_color.rgb, noise), depth_diff);
    vec3 base_color = mix(refracted, water_tint, clamp(depth_diff * 1.5, 0.15, 0.95));

    // --- Écume de berge ---
    float foam_noise = texture(noise_tex, world_uv * foam_noise_scale + vec2(TIME * 0.02, 0.0)).r;
    float foam_edge = 1.0 - smoothstep(0.0, foam_band_width, depth_diff);
    foam_edge *= smoothstep(0.3, 0.7, foam_noise + 0.3);

    // --- Mousse/algues flottantes ---
    vec2 scum_scroll = world_uv + vec2(TIME * scum_scroll_speed, TIME * scum_scroll_speed * 0.7);
    float scum_noise = texture(noise_tex_large, scum_scroll).r;
    float scum_mask = smoothstep(scum_density, scum_density + 0.1, scum_noise);
    scum_mask *= 1.0 - smoothstep(scum_threshold, scum_threshold + 0.2, depth_diff);

    // --- Composition finale ---
    vec3 final_color = base_color;
    final_color = mix(final_color, scum_color.rgb, scum_mask * 0.7);
    final_color = mix(final_color, foam_color.rgb, foam_edge);

    // --- Fondu des bords du mesh (évite les arêtes visibles au loin) ---
    float dist_to_edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
    float edge_alpha = smoothstep(0.0, edge_fade_width, dist_to_edge);

    ALBEDO = final_color;
    ROUGHNESS = mix(roughness_val, 0.9, max(foam_edge, scum_mask));
    METALLIC = 0.0;
    ALPHA = edge_alpha;
}