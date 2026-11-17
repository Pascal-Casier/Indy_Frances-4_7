shader_type spatial;
render_mode unshaded, cull_back, blend_mix, depth_draw_always;

// ============================================================
//  Portal Cube Shader (Godot 4.x)
//  Chaque face du cube affiche un vortex en spirale avec un effet
//  de tunnel (parallaxe) qui donne l'illusion de profondeur.
//  Pour un cube de taille 1x1x1 (BoxMesh par défaut) : cube_half_size = 0.5
// ============================================================

group_uniforms colors;
uniform vec4 color_core : source_color = vec4(1.0, 0.85, 1.0, 1.0);
uniform vec4 color_mid  : source_color = vec4(0.55, 0.15, 1.0, 1.0);
uniform vec4 color_edge : source_color = vec4(0.05, 0.75, 1.0, 1.0);

group_uniforms animation;
uniform float speed : hint_range(0.0, 4.0) = 0.6;
uniform float twist : hint_range(0.0, 10.0) = 3.0;
uniform float arms : hint_range(1.0, 12.0, 1.0) = 4.0;
uniform float noise_scale : hint_range(0.5, 6.0) = 2.0;

group_uniforms shape;
uniform float cube_half_size = 0.5;
uniform float tunnel_depth : hint_range(0.0, 2.0) = 0.7;
uniform float core_size : hint_range(0.5, 8.0) = 2.5;
uniform float frame_width : hint_range(0.0, 0.3) = 0.06;

group_uniforms look;
uniform float intensity : hint_range(0.0, 6.0) = 1.8;
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;
uniform float alpha_base : hint_range(0.0, 1.0) = 0.9;

varying vec3 v_pos;
varying vec3 v_nrm;
varying vec3 v_view_local;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
		f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(17.3, 9.1);
		a *= 0.5;
	}
	return v;
}

// Projette un vecteur 3D sur le plan de la face selon la normale locale
vec2 face_coords(vec3 v, vec3 n) {
	vec3 an = abs(n);
	if (an.x > 0.5) return v.zy;
	if (an.y > 0.5) return v.xz;
	return v.xy;
}

void vertex() {
	v_pos = VERTEX;
	v_nrm = NORMAL;
	vec3 cam_local = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	v_view_local = VERTEX - cam_local; // direction caméra -> point (espace local)
}

void fragment() {
	vec3 n = normalize(v_nrm);
	vec3 d = normalize(v_view_local);

	// Coordonnées de la face dans [-1, 1]
	vec2 uv = face_coords(v_pos, n) / cube_half_size;

	// Parallaxe : on "regarde" à l'intérieur du cube
	vec2 vd = face_coords(d, n);
	float dn = max(abs(dot(d, n)), 0.15);
	vec2 uvp = uv + (vd / dn) * tunnel_depth * 0.3;

	// Coordonnées polaires
	float r = length(uvp);
	float a = atan(uvp.y, uvp.x);

	// Coordonnée de tunnel : défile vers le centre
	float z = 0.4 / (r + 0.1) + TIME * speed;

	// Spirale (périodique, donc sans couture)
	float swirl = sin(arms * a + twist * z - TIME * speed * 2.0) * 0.5 + 0.5;

	// Turbulence type "énergie" (sans couture grâce à cos/sin)
	vec2 np = vec2(cos(a), sin(a)) * noise_scale + vec2(z, -z * 0.6);
	float energy = fbm(np);

	float pattern = clamp(mix(swirl, energy, 0.5) + energy * 0.25, 0.0, 1.0);

	// Couleurs
	vec3 col = mix(color_edge.rgb, color_mid.rgb, pattern);
	float core = exp(-r * core_size);
	col = mix(col, color_core.rgb, clamp(core, 0.0, 1.0));

	// Cadre lumineux sur les bords de chaque face
	float m = max(abs(uv.x), abs(uv.y));
	float frame = smoothstep(1.0 - frame_width * 2.0, 1.0 - frame_width * 0.5, m);
	col += color_edge.rgb * frame * 1.5;

	// Effet Fresnel sur les bords du cube
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	col += color_edge.rgb * fres;

	ALBEDO = col * intensity;
	ALPHA = clamp(alpha_base * (0.55 + pattern * 0.45) + frame + core * 0.5 + fres * 0.3, 0.0, 1.0);
}
