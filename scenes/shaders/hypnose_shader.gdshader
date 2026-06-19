shader_type canvas_item;

uniform float time_scale : hint_range(0.1, 5.0) = 1.0; // Contrôle la vitesse de l'effet
uniform float distortion_strength : hint_range(0.0, 0.5) = 0.1; // Force de la distorsion
uniform float swirl_strength : hint_range(0.0, 2.0) = 0.5; // Force du tourbillon
uniform vec4 color_shift : source_color = vec4(1.0, 0.5, 0.2, 1.0); // Décalage des couleurs

void fragment() {
    vec2 uv = UV; // Coordonnées UV du pixel
    float time = TIME * time_scale; // Temps animé

    // Créer une distorsion basée sur des cercles concentriques
    vec2 center = vec2(0.5, 0.5); // Centre de l'effet
    float dist = length(uv - center); // Distance au centre
    uv += sin(dist * 10.0 + time) * distortion_strength; // Distorsion ondulante

    // Ajouter un effet de tourbillon
    float angle = swirl_strength * sin(time + dist * 5.0);
    vec2 swirled_uv = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle))) * (uv - center) + center;

    // Créer un motif hypnotique (par exemple, anneaux concentriques)
    float pattern = sin(dist * 20.0 + time) * 0.5 + 0.5;

    // Calculer les couleurs avec un effet psychédélique
    vec3 color = vec3(
        sin(pattern + time) * color_shift.r,
        cos(pattern + time * 0.7) * color_shift.g,
        sin(pattern + time * 1.3) * color_shift.b
    );

    // Appliquer la couleur finale
    COLOR = vec4(color, 1.0);
}