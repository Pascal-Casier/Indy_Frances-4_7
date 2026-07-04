shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// === Couleurs de la boue ===
uniform vec4 mud_color_dry : source_color = vec4(0.25, 0.16, 0.10, 1.0);
uniform vec4 mud_color_wet : source_color = vec4(0.10, 0.06, 0.04, 1.0);
uniform vec4 puddle_color : source_color = vec4(0.05, 0.05, 0.04, 1.0);

// === Paramètres de texture procédurale ===
uniform float noise_scale : hint_range(1.0, 50.0) = 12.0;
uniform float detail_scale : hint_range(1.0, 200.0) = 60.0;
uniform float bump_strength : hint_range(0.0, 2.0) = 0.6;

// === Humidité / flaques ===
uniform float wetness : hint_range(0.0, 1.0) = 0.5;      // 0 = boue sèche, 1 = boue détrempée
uniform float puddle_threshold : hint_range(0.0, 1.0) = 0.65; // seuil au-dessus duquel une flaque apparaît
uniform float puddle_smoothness : hint_range(0.001, 0.5) = 0.08;

// === Réflexion / brillance ===
uniform float roughness_dry : hint_range(0.0, 1.0) = 0.95;
uniform float roughness_wet : hint_range(0.0, 1.0) = 0.15;
uniform float fresnel_power : hint_range(0.1, 8.0) = 3.0;

// === Optionnel : texture de traces (pneus, pas) ===
uniform sampler2D tracks_texture : hint_default_black;
uniform float tracks_strength : hint_range(0.0, 1.0) = 0.0;

varying vec3 world_pos;

// ---- Bruit de valeur simple (2D) ----
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amplitude * noise(p);
		p *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

void vertex() {
	world_pos = VERTEX;
}

void fragment() {
	vec2 uv = world_pos.xz; // projection planaire, utile pour un sol

	// Grande variation d'humidité / de flaques
	float big_noise = fbm(uv * (noise_scale * 0.1));
	// Détail fin (grumeaux de boue)
	float fine_noise = fbm(uv * (detail_scale * 0.1));

	// Carte d'humidité locale (combine humidité globale + variation)
	float wet_map = clamp(wetness + (big_noise - 0.5) * 0.6, 0.0, 1.0);

	// Masque de flaques : zones où l'humidité dépasse le seuil
	float puddle_mask = smoothstep(puddle_threshold - puddle_smoothness, puddle_threshold + puddle_smoothness, wet_map);

	// Couleur de base : mélange sec -> humide
	vec3 base_color = mix(mud_color_dry.rgb, mud_color_wet.rgb, wet_map);
	// Ajoute des grumeaux/variations de teinte
	base_color *= 0.9 + 0.2 * fine_noise;

	// Traces de pneus / pas (optionnel)
	if (tracks_strength > 0.0) {
		float track = texture(tracks_texture, UV).r;
		base_color = mix(base_color, base_color * 0.6, track * tracks_strength);
		wet_map = clamp(wet_map + track * tracks_strength * 0.5, 0.0, 1.0);
	}

	// Flaques : couleur sombre et quasi spéculaire
	vec3 final_color = mix(base_color, puddle_color.rgb, puddle_mask);

	// Rugosité : la boue sèche est mate, l'eau est très lisse
	float roughness = mix(roughness_dry, roughness_wet, wet_map);
	roughness = mix(roughness, 0.03, puddle_mask); // flaques quasi miroir

	// Relief procédural (bump via dérivées du bruit, sans vraie normal map)
	float eps = 1.0 / detail_scale;
	float h_c = fine_noise;
	float h_x = fbm((uv + vec2(eps, 0.0)) * (detail_scale * 0.1));
	float h_y = fbm((uv + vec2(0.0, eps)) * (detail_scale * 0.1));
	vec3 bump_normal = normalize(vec3((h_c - h_x) * bump_strength, (h_c - h_y) * bump_strength, 1.0));
	// Aplatit le relief sous les flaques (surface liquide lisse)
	bump_normal = normalize(mix(bump_normal, vec3(0.0, 0.0, 1.0), puddle_mask));

	ALBEDO = final_color;
	ROUGHNESS = roughness;
	METALLIC = 0.0;
	SPECULAR = mix(0.3, 0.9, wet_map);
	NORMAL_MAP = bump_normal * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = 1.0;
}
