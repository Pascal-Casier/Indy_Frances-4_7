shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ============================================================
//  TEXTURES
// ============================================================
uniform sampler2D ground_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D cliff_texture  : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D top_texture    : source_color, filter_linear_mipmap, repeat_enable;

// ============================================================
//  PARAMETRES REGLABLES DEPUIS L'INSPECTEUR
// ============================================================

// Hauteur (coordonnee Y monde) a partir de laquelle la texture "top" apparait
uniform float top_min_height = 10.0;
// Largeur de la zone de transition douce autour du seuil de hauteur
uniform float top_height_blend : hint_range(0.0, 20.0) = 1.5;

// Seuil de pente : 1.0 = totalement plat, 0.0 = totalement vertical.
// En dessous de ce seuil -> texture de falaise
uniform float slope_threshold : hint_range(0.0, 1.0) = 0.7;
// Largeur de la zone de transition douce autour du seuil de pente
uniform float slope_blend : hint_range(0.001, 0.5) = 0.1;

// Echelle des textures pour le mapping triplanaire
uniform float texture_scale = 0.2;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// Echantillonnage triplanaire : projette la texture sur les 3 axes
// et mélange selon l'orientation de la normale. Evite l'étirement
// sur les surfaces verticales (falaises).
vec4 triplanar(sampler2D tex, vec3 pos, vec3 normal, float scale) {
    vec3 blend_weights = abs(normal);
    blend_weights = pow(blend_weights, vec3(4.0));
    blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z + 0.00001);

    vec4 x_proj = texture(tex, pos.yz * scale);
    vec4 y_proj = texture(tex, pos.xz * scale);
    vec4 z_proj = texture(tex, pos.xy * scale);

    return x_proj * blend_weights.x + y_proj * blend_weights.y + z_proj * blend_weights.z;
}

void fragment() {
    vec3 n = normalize(world_normal);

    // 1.0 = surface horizontale, 0.0 = surface verticale
    float slope = dot(n, vec3(0.0, 1.0, 0.0));

    vec4 ground_color = triplanar(ground_texture, world_pos, n, texture_scale);
    vec4 cliff_color  = triplanar(cliff_texture,  world_pos, n, texture_scale);
    vec4 top_color    = triplanar(top_texture,    world_pos, n, texture_scale);

    // Facteur pente : 0 = falaise, 1 = sol
    float slope_factor = smoothstep(slope_threshold - slope_blend, slope_threshold + slope_blend, slope);

    // Mélange sol / falaise selon la pente
    vec4 base_color = mix(cliff_color, ground_color, slope_factor);

    // Facteur hauteur : 0 = pas encore "top", 1 = top
    float height_factor = smoothstep(top_min_height - top_height_blend, top_min_height + top_height_blend, world_pos.y);

    // Le top ne doit apparaitre que sur les zones plates, pas sur les falaises
    height_factor *= slope_factor;

    vec4 final_color = mix(base_color, top_color, height_factor);

    ALBEDO = final_color.rgb;
    METALLIC = 0.0;
    ROUGHNESS = 0.9;
}