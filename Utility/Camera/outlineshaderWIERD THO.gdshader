shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.2, 0.6, 1.0, 1.0); // Blue outline
uniform float thickness = 2.0; // Outline thickness in pixels

void fragment() {
    vec2 size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 uv_px = FRAGCOORD.xy;

    float left   = step(uv_px.x, SCREEN_UV.x * size.x + thickness);
    float right  = step((1.0 - SCREEN_UV.x) * size.x + thickness, size.x - uv_px.x);
    float top    = step(uv_px.y, SCREEN_UV.y * size.y + thickness);
    float bottom = step((1.0 - SCREEN_UV.y) * size.y + thickness, size.y - uv_px.y);

    float outline = max(max(left, right), max(top, bottom));

    if (outline > 0.0) {
        COLOR = outline_color;
    } else {
        discard; // Transparent center
    }
}
