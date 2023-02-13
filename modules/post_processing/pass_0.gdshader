//shader_type canvas_item;
//
//uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
//uniform vec2 size = vec2(32.0, 28.0);
//
//void fragment() {
//        vec2 norm_size = size * SCREEN_PIXEL_SIZE;
//        bool half = mod(SCREEN_UV.y / 2.0, norm_size.y) / norm_size.y < 0.5;
//        vec2 uv = SCREEN_UV + vec2(norm_size.x * 0.5 * float(half), 0.0);
//        vec2 center_uv = floor(uv / norm_size) * norm_size;
//        vec2 norm_uv = mod(uv, norm_size) / norm_size;
//        center_uv += mix(vec2(0.0, 0.0),
//                         mix(mix(vec2(norm_size.x, -norm_size.y),
//                                 vec2(0.0, -norm_size.y),
//                                 float(norm_uv.x < 0.5)),
//                             mix(vec2(0.0, -norm_size.y),
//                                 vec2(-norm_size.x, -norm_size.y),
//                                 float(norm_uv.x < 0.5)),
//                             float(half)),
//                         float(norm_uv.y < 0.3333333) * float(norm_uv.y / 0.3333333 < (abs(norm_uv.x - 0.5) * 2.0)));
//
//        COLOR = textureLod(screen_texture, center_uv, 0.0);
//}

shader_type canvas_item;
render_mode blend_mix,unshaded;

uniform float brightness : hint_range(-1, 1) = 0;
uniform float contrast : hint_range(0, 3) = 1.0;
uniform float saturation : hint_range(0, 3) = 1.0;

uniform float saturation_red_factor : hint_range(0, 1) = 1.0;
uniform float saturation_green_factor : hint_range(0, 1) = 1.0;
uniform float saturation_blue_factor : hint_range(0, 1) = 1.0;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_effect_factor : hint_range(0, 1) = 0.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

//---------------------------------------------
//CONTRAST
//---------------------------------------------
mat4 contrastMatrix( float _contrast ){
	float t = ( 1.0 - _contrast ) / 2.0;
    return mat4( 
		vec4(_contrast, 0, 0, 0),
		vec4(0, _contrast, 0, 0),
		vec4(0, 0, _contrast, 0),
		vec4(t, t, t, 1));
}
//---------------------------------------------
//BRIGHTNESS
//---------------------------------------------
mat4 brightnessMatrix( float _brightness ){
    return mat4( vec4(1, 0, 0, 0),
                 vec4(0, 1, 0, 0),
                 vec4(0, 0, 1, 0),
                 vec4(_brightness, _brightness, _brightness, 1));
}
//---------------------------------------------
//SATURATION
//---------------------------------------------
mat4 saturationMatrix( float _saturation ){
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    float oneMinusSat = 1.0 - _saturation;
	
    vec3 red = vec3(luminance.x * oneMinusSat);
    red+= vec3(_saturation, 0, 0) * saturation_red_factor;
    vec3 green = vec3(luminance.y * oneMinusSat);
    green += vec3(0,_saturation, 0) * saturation_green_factor;
    vec3 blue = vec3(luminance.z * oneMinusSat);
    blue += vec3(0, 0,_saturation) * saturation_blue_factor;
	
    return mat4(vec4(red, 0),vec4(green,0),vec4(blue,0),vec4(0, 0, 0, 1));
}

//---------------------------------------------
//fragment
//---------------------------------------------
void fragment() {
	vec4 c = textureLod(screen_texture, UV, 0.0);
	vec4 c2 = c * tint_color;
	COLOR = brightnessMatrix( brightness ) * contrastMatrix( contrast ) *saturationMatrix( saturation ) * mix(c, c2, tint_effect_factor);
}