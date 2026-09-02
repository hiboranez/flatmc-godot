shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // 如果当前像素在 progress 以上的区域（即更靠上的部分），则透明
    if (UV.y < 1.0 - progress) {
        tex_color.a = 0.0;
    }

    COLOR = tex_color;
}
