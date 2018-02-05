vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 textureColor = Texel(texture, texture_coords);
    vec3 resultColor = color.rgb * (1.0f - textureColor.a) + textureColor.rgb * textureColor.a;
    return vec4(resultColor, 1.0f - textureColor.a);
    // FIX ME!
}
