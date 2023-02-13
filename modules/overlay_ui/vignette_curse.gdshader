//Custom version of Shader from Del : https://www.shadertoy.com/view/MtXfDj#
shader_type canvas_item;

uniform float distortion = 4.0;						// increase or decrease to suit your taste.
uniform float zoom = 0.7;							// zoom value
uniform float gooeyness = 0.95;						// smaller = more gooey bits
uniform float wibble = 0.5;							// tweak the wibble!
uniform float saturation = 2.4;
uniform vec4 primary_color : source_color = vec4(0.94,0.0,0.14,0.2);
uniform vec4 secondary_color : source_color = vec4(0.3,0.0,1.0,0.5);
uniform sampler2D noiseSampler;
uniform float speed = 0.4;

// GooFunc - now with technical parameters for you to play with :)
float GooFunc(vec2 uv)
{
    float s = sin(TIME*speed);
    float s2 = 0.5+sin(TIME*speed);
    vec2 d = uv*(distortion+s*.3);
    d.x += TIME*speed*0.25+sin(d.x+d.y + TIME*speed*0.3)*wibble;
    d.y += TIME*speed*0.25+sin(d.x + TIME*speed*0.3)*wibble;
    float v1=length(0.5-fract(d.xy))+gooeyness;
    d = (1.0-zoom)*0.5+(uv*zoom);					// try removing this :)
    float v2=length(0.5-fract(d.xy));
    v1 *= 1.0-v2*v1;
    v1 = v1*v1*v1;
    v1 *= 1.9+s2*0.2;
    return v1;
}

void fragment() {
    float goo = GooFunc(UV);
    COLOR = mix(secondary_color,primary_color,goo)*saturation;

    float avg = max(max(COLOR.r,COLOR.g),COLOR.b);		//float avg = k.g;	//(k.r+k.g+k.b)/3.0;
    float alpha=1.0;
    if (COLOR.r>=0.5)
    {
        // darken & alpha edge of goo...
        avg = clamp(avg,0.0,1.0);
        COLOR*=avg+0.2;						// 0.0 = black edges
        alpha = clamp((avg*avg)*5.5,0.0,1.0);
    }

    // blend goo + background based on the Alpha
    COLOR = mix(vec4(0,0,0,0),COLOR,alpha);
	COLOR.a *= texture(noiseSampler, 0.1*UV+TIME*speed*0.01).r;
}
