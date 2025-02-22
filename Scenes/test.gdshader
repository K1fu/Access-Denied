shader_type canvas_item;

// Overlay textures for red, green, and blue channels.
uniform sampler2D overlay_tex_red : repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_green : repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_blue : repeat_enable, filter_nearest;

// Scale factors for mapping each overlay texture independently on x and y axes.
uniform vec2 scale_r = vec2(0.5, 0.7);  // Default scale for red channel
uniform vec2 scale_g = vec2(0.3, 0.4);  // Default scale for green channel
uniform vec2 scale_b = vec2(1.0, 1.0);  // Default scale for blue channel

// Global scaling factor to combine with individual scaling.
uniform vec2 global_scale = vec2(1.0, 1.0);  // Global scale for all textures

// Multiplier to make scaling easier to control.
uniform float scale_multiplier = 10.0;  // Adjust this for finer control

// A varying variable to store world-space position for texture mapping.
varying vec2 world_position;

void vertex() {
    // Compute world-space position of the vertex.
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
    // Combine global scaling with individual scaling factors.
    vec2 combined_scale_r = (scale_r * global_scale) / scale_multiplier;
    vec2 combined_scale_g = (scale_g * global_scale) / scale_multiplier;
    vec2 combined_scale_b = (scale_b * global_scale) / scale_multiplier;

    // Sample the overlay textures with combined scaling for x and y.
    vec4 overlay_red = texture(overlay_tex_red, world_position * combined_scale_r);
    vec4 overlay_green = texture(overlay_tex_green, world_position * combined_scale_g);
    vec4 overlay_blue = texture(overlay_tex_blue, world_position * combined_scale_b);

    // Apply overlays based on the respective color channels.
    float mix_r = floor(COLOR.r);
    float mix_g = floor(COLOR.g);
    float mix_b = floor(COLOR.b);

    // Blend overlays with the base color.
    COLOR = mix(COLOR, overlay_red, mix_r);
    COLOR = mix(COLOR, overlay_green, mix_g);
    COLOR = mix(COLOR, overlay_blue, mix_b);
}