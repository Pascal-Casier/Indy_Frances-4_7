shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_albedo; // Texture de lave
uniform float speed = 0.1; // Vitesse du mouvement
uniform float wave_strength = 0.1; // Intensité des vagues
uniform float uv_scale = 5.0; // Facteur de répétition de la texture
uniform float scale_variation = 0.1; // Amplitude de la variation d'échelle

void vertex() {
    // Déplacer légèrement les sommets pour un effet 3D subtil
    VERTEX.y += sin(TIME * 2.0 + VERTEX.x) * wave_strength;
}

void fragment() {
    // Calculer une variation d'échelle dynamique
    float scale_factor = 1.0 + sin(TIME * speed * 0.5) * scale_variation;

    // Scaler les UV avec la répétition et la variation
    vec2 uv = UV * uv_scale * scale_factor;
    uv.y += sin(TIME * speed + uv.x * 10.0) * wave_strength; // Mouvement ondulé
    uv.y -= TIME * speed * 0.5; // Défilement vertical

    // Appliquer la texture avec les UV modifiées
    vec4 color = texture(texture_albedo, uv);

    // Ajouter une teinte rouge/orange pour l'effet lave
    color.rgb = mix(color.rgb, vec3(1.0, 0.3, 0.0), 0.3);

    // Émettre une lumière simple
    ALBEDO = color.rgb;
    EMISSION = color.rgb * 0.8;
}