shader_type canvas_item;

uniform vec2 shadow_offset = vec2(2.0, 2.0); // 阴影偏移（单位：像素）
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5); // 阴影颜色

void fragment() {
    // 原字体颜色
    vec4 original = texture(TEXTURE, UV);

    // 阴影采样点
    vec2 shadow_uv = UV - shadow_offset / TEXTURE_PIXEL_SIZE;
    vec4 shadow = texture(TEXTURE, shadow_uv);

    // 只使用阴影的透明度（alpha）与阴影颜色混合
    vec4 shadow_result = shadow_color * shadow.a;

    // 最终颜色 = 阴影 + 字体（前景优先）
    COLOR = mix(shadow_result, original, original.a);
}
