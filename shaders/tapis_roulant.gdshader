shader_type spatial;

// Paramètres du tapis roulant
uniform sampler2D texture_albedo : source_color, filter_nearest;
uniform vec2 scroll_speed = vec2(1.0, 0.0); // Vitesse de défilement (X, Y)
uniform float speed_multiplier = 1.0; // Multiplicateur de vitesse
uniform vec2 texture_scale = vec2(1.0, 1.0); // Scale/Tiling de la texture

void fragment() {
    // Appliquer le scale aux UV
    vec2 scaled_uv = UV * texture_scale;
    
    // Calculer le décalage UV basé sur le temps
    vec2 uv_offset = scroll_speed * TIME * speed_multiplier;
    
    // Appliquer le décalage aux coordonnées UV
    vec2 scrolling_uv = scaled_uv + uv_offset;
    
    // Échantillonner la texture avec les UV décalées
    vec4 albedo_tex = texture(texture_albedo, scrolling_uv);
    
    // Appliquer la couleur
    ALBEDO = albedo_tex.rgb;
    ALPHA = albedo_tex.a;
}