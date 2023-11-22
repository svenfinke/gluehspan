shader_type canvas_item;

void fragment()
{
	vec2 new_uv = vec2(UV.x + sin(TIME) * 0.005, UV.y);
	COLOR = texture(TEXTURE, new_uv);
}