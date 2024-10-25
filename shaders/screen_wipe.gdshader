shader_type canvas_item;
// Sreen Wipe Shader
// https://c.eev.ee/particle-wipe-generator/

//precision mediump float;

uniform sampler2D mask;
uniform sampler2D before;
uniform sampler2D after;
// This is the progress through the transition, from 0 to 1
uniform float t;
// This is the "ramp" slider from under the player
uniform float ramp;

// These are the texture coordinates from the vertex shader.  Depending on
// the exact effect you want, you might want to use screen coordinates, or
// something else entirely.
varying vec2 tex_coords;

// I suppose this wouldn't be necessary if you had premultiplied alpha, but
// who does that, right?
vec4 alpha_composite(vec4 top, vec4 bottom) {
    float alpha = top.a + bottom.a * (1.0 - top.a);
    return vec4((top.rgb * top.a + bottom.rgb * (bottom.a * (1.0 - top.a))) / alpha, alpha);
}

void fragment() {
    // Sample the same spot in before, after, and the mask itself...
    vec4 before_pixel = texture(before, tex_coords);
    vec4 after_pixel = texture(after, tex_coords);
    vec4 mask_pixel = texture(mask, tex_coords);
    // Collect all the mask channels together into a single value
    float discriminator = mask_pixel.r + mask_pixel.g / 256.0 + mask_pixel.b / 65536.0;
    // The ramp adds a little fuzz around the current value.  This scales t
    // so that 0 means just before the first hint of the ramp appears;
    // otherwise, half a ramp would abruptly appear when the effect starts.
    float scaled_t = t * (1.0 + ramp * 2.0) - ramp;
    // This is the alpha of the "after" image.
    float alpha = clamp((scaled_t - discriminator) / ramp + 0.5, 0.0, 1.0);
    // Multiply, in case it already has its own alpha.
    after_pixel.a *= alpha;
    // Finally, composite!
    // You might also want to draw the "after" image on top of some
    // existing scene, rather than combining before/after in a single
    // shader.  In that case, just use after_pixel directly here, and
    // delete all the "before" stuff.
	COLOR = after_pixel;
    //COLOR = alpha_composite(after_pixel, before_pixel);
}