shader_type spatial;

uniform vec4 rim_color : source_color = vec4(0.6, 0.9, 1.0, 1.0);
uniform float rim_power = 3.0;
uniform float alpha_strength = 0.2;
uniform float pulse_speed = 1.5;

void fragment() {
    // Approximation de la direction vue (depuis la caméra vers le pixel)
    vec3 view_dir = normalize(-VERTEX);

    float rim = pow(1.0 - dot(NORMAL, view_dir), rim_power);
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    vec3 color = mix(vec3(0.0, 0.2, 0.4), rim_color.rgb, rim);
    ALBEDO = color;
    ALPHA = alpha_strength + rim * 0.5 + pulse * 0.1;
}

void vertex() {
    VERTEX += NORMAL * 0.02 * sin(TIME * 2.0 + VERTEX.y * 5.0);
}
