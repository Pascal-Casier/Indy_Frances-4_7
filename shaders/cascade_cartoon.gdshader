shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_toon;

// ============================================================
//  SHADER : Cascade d'eau style cartoon
//  A appliquer sur un mesh plan (ou légèrement incurvé) vertical
//  représentant le "rideau" d'eau de la cascade.
// ============================================================

uniform vec4 water_color : source_color = vec4(0.35, 0.75, 0.95, 0.85);
uniform vec4 water_color_dark : source_color = vec4(0.15, 0.45, 0.75, 0.9);
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform sampler2D noise_texture; // assigner une NoiseTexture2D (bruit type Perlin/Simplex)

uniform float flow_speed : hint_range(0.0, 5.0) = 1.8;      // vitesse de chute
uniform float tiling : hint_range(0.1, 10.0) = 3.0;         // répétition du motif
uniform float foam_amount : hint_range(0.0, 1.0) = 0.4;     // quantité d'écume
uniform float cel_steps : hint_range(1.0, 10.0) = 4.0;      // nombre de "bandes" cartoon
uniform float distortion_strength : hint_range(0.0, 0.3) = 0.06;
uniform float wave_amplitude : hint_range(0.0, 0.2) = 0.03; // ondulation du mesh
uniform float wave_frequency : hint_range(0.0, 10.0) = 4.0;
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.35;

varying vec2 world_uv;

// -------- fonctions utilitaires --------
float posterize(float value, float steps) {
    return floor(value * steps) / steps;
}

void vertex() {
    world_uv = UV;

    // légère ondulation horizontale pour casser la rigidité du plan
    float wave = sin(UV.y * wave_frequency + TIME * flow_speed) * wave_amplitude;
    VERTEX.x += wave;
}

void fragment() {
    vec2 uv = UV * tiling;

    // Deux couches de bruit qui défilent vers le bas à des vitesses différentes
    float t = TIME * flow_speed;
    vec2 flow_uv1 = uv + vec2(0.0, t);
    vec2 flow_uv2 = uv * 1.6 + vec2(0.35, t * 1.35);

    float noise1 = texture(noise_texture, fract(flow_uv1)).r;
    float noise2 = texture(noise_texture, fract(flow_uv2)).r;
    float combined_noise = mix(noise1, noise2, 0.5);

    // Bandes façon cartoon (au lieu d'un dégradé lisse)
    float banded = posterize(combined_noise, cel_steps);

    // Couleur de base : dégradé entre foncé et clair selon les bandes
    vec3 base_color = mix(water_color_dark.rgb, water_color.rgb, banded);

    // Écume : apparaît où le bruit combiné est fort (crêtes de la chute)
    float foam_mask = smoothstep(1.0 - foam_amount, 1.0, combined_noise);
    // on ajoute un peu d'écume statique en haut et en bas (impact / départ)
    foam_mask = max(foam_mask, smoothstep(0.95, 1.0, UV.y));
    foam_mask = max(foam_mask, smoothstep(0.05, 0.0, UV.y) * 0.6);

    vec3 final_color = mix(base_color, foam_color.rgb, foam_mask);

    // Contour lumineux (rim) pour un rendu "toon" plus marqué sur les bords
    float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), rim_power);
    final_color += fresnel * rim_strength * foam_color.rgb;

    ALBEDO = final_color;
    ALPHA = mix(water_color.a, 1.0, foam_mask); // l'écume est plus opaque

    // Distortion légère de la normale pour un effet d'eau vivante sans être réaliste
    vec2 distortion = vec2(noise2 - 0.5, noise1 - 0.5) * distortion_strength;
    NORMAL_MAP = vec3(distortion, 1.0);
}
