shader_type canvas_item;

uniform vec4 blink_color: source_color;
uniform float blink_intensity = 0;
uniform float dissolve_intensity = 0;   // 溶解强度
uniform float transparent_intensity = 0; // 透明度强度，从0到1控制透明度

// 随机生成噪声，用于模拟像素块化的溶解效果
float random(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // 生成一个基于UV的随机值
    float noise = random(floor(UV * 10.0)); // 使用UV坐标来控制噪声块的大小
    
    // 根据溶解强度和噪声值判断是否让该像素块消失
    float dissolve_factor = smoothstep(0.4, 0.6, -dissolve_intensity + noise);
    
    // 应用溶解效果
    color.a *= dissolve_factor;
    
    // 应用透明度强度
    color.a *= (1.0 - transparent_intensity); // 透明度随着 transparent_intensity 增加而降低

    // 混合颜色，增加闪烁效果
    color = mix(color, blink_color, blink_intensity * color.a);
    
    COLOR = color;
}