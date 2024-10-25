shader_type canvas_item;
render_mode blend_mix;
uniform float y_top;
uniform float y_bottom;
uniform sampler2D gradient;

void fragment() {
	float y_rel = UV.y - y_top;
	float height = y_bottom - y_top;
	float dist_height = y_bottom - y_top;
	vec2 new_uv = vec2(y_rel / height, 0.0);
	if (UV.y > y_bottom)
		COLOR.r = 0.0;
	else if (UV.y < y_top)
		COLOR.b = 0.0;
	else
		COLOR.rgb = COLOR.rgb * texture(gradient, new_uv).rgb;
}