shader_type canvas_item;

uniform bool is_mouse_over = false;

void fragment() {
	vec4 local_color = texture(TEXTURE, UV);
	if (is_mouse_over){
		vec4 outline_color_1 = vec4(0.247, 0.149, 0.192, 1);
		vec4 outline_color_2 = vec4(0.149, 0.169, 0.267, 1);
		
		if (round(local_color) == round(outline_color_1) || round(local_color) == round(outline_color_2)) {
			local_color = vec4(1,1,1,1);
		}
	}	
	COLOR = local_color;
}
