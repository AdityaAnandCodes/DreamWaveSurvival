shader_type spatial;
render_mode blend_mix;

uniform sampler2D noise_texture;
uniform sampler2D texture_mask;
uniform float emission_intensity = 2.0;
uniform float time_scale = 3.0;
uniform vec2 texture_scale = vec2(1.0);
uniform float edge_softness = 0.1;

varying vec3 world_coord;
varying float world_x_dot;

void vertex() {
    // Transform the vertex position to world space using MODEL_MATRIX
    world_coord = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Calculate the normal in world space
    vec3 world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);

    // Compute the dot product with the world x-axis
    world_x_dot = abs(dot(world_normal, vec3(1.0, 0.0, 0.0)));
}

void fragment() {
    // Fetch the mask texture
    float mask = texture(texture_mask, UV).r;

    // Calculate time-based UV pan for noise animation
    vec2 time_based_pan = vec2(0.2, 1.0) * (-TIME * time_scale);

    // Sample noise textures using world coordinates
    float noise_xy = texture(noise_texture, world_coord.xy * texture_scale + time_based_pan).r;
    float noise_zy = texture(noise_texture, world_coord.zy * texture_scale + time_based_pan + vec2(0.7, 0.3)).r;

    // Mix the two noise samples based on the x-axis dot product
    float noise = mix(noise_xy, noise_zy, clamp(world_x_dot, 0.0, 1.0));

    // Set the base albedo color
    ALBEDO = COLOR.rgb;

    // Set the emission color based on the albedo
    EMISSION = ALBEDO * emission_intensity;

    // Calculate erosion and alpha
    float erosion_amount = (1.0 - COLOR.a);
    float alpha = (noise * mask) - erosion_amount;

    // Smoothly adjust the alpha
    alpha = clamp(alpha, 0.0, 1.0);
    ALPHA = smoothstep(0.0, edge_softness, alpha);
}
