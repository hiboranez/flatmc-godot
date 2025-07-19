shader_type canvas_item;

uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform vec2 shadow_offset = vec2(2.0, 2.0);
uniform float shadow_smoothness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // 先采样阴影部分
    vec4 shadow = texture(TEXTURE, UV - shadow_offset / TEXTURE_PIXEL_SIZE) * shadow_color;
    
    // 再采样原始文本
    vec4 text = texture(TEXTURE, UV);
    
    // 混合阴影和文本
    COLOR = mix(shadow, text, text.a);
    
    // 添加平滑效果
    if (shadow_smoothness > 0.0) {
        float shadow_alpha = texture(TEXTURE, UV - shadow_offset / TEXTURE_PIXEL_SIZE).a;
        float smooth_edge = smoothstep(0.0, shadow_smoothness, shadow_alpha);
        COLOR = mix(COLOR, shadow, smooth_edge * shadow_color.a);
    }
}