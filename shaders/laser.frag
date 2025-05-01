// modified from : https://www.shadertoy.com/view/XtBXW3
// modified by: @zeyus
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float time;

out vec4 fragColor;



vec2 rotate(vec2 point, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(
        point.x * c - point.y * s,
        point.x * s + point.y * c
    );
}

vec3 Strand(in vec2 fragCoord, in vec3 color, in float hoffset, in float hscale, in float vscale, in float timescale)
{
    float glow = 0.06 * uSize.y;
    float twopi = 6.28318530718;
    float muzzleDist = clamp(2*(1-fragCoord.x/uSize.x), 0.000001, 1.0);
    float curve = 1.0 - abs(fragCoord.y - (sin(mod(fragCoord.x * hscale / 100.0 / uSize.x * 1000.0 + time * timescale + hoffset, twopi)) * uSize.y * 0.05 * vscale * muzzleDist + uSize.y / 2.0));
    float i = clamp(curve, 0.0, 1.0);
    // i += clamp((glow + curve) / glow, 0.0, 1.0) * 0.1 ;
    return i * color;
}

void main()
{
    vec2 fragCoord = FlutterFragCoord();
        

    float timescale = 0.5;
	vec3 c = vec3(0, 0, 0);
    c += Strand(fragCoord, vec3(1.0, 0, 0), 0.7934 + 1.0 + sin(time) * 30.0, 1.0, 0.16, 10.0 * timescale);
    c += Strand(fragCoord, vec3(0.0, 1.0, 0.0), 0.645 + 1.0 + sin(time) * 30.0, 1.5, 0.2, 10.3 * timescale);
    c += Strand(fragCoord, vec3(0.0, 0.0, 1.0), 0.735 + 1.0 + sin(time) * 30.0, 1.3, 0.19, 8.0 * timescale);
    c += Strand(fragCoord, vec3(1.0, 1.0, 0.0), 0.9245 + 1.0 + sin(time) * 30.0, 1.6, 0.14, 12.0 * timescale);
    c += Strand(fragCoord, vec3(0.0, 1.0, 1.0), 0.7234 + 1.0 + sin(time) * 30.0, 1.9, 0.23, 14.0 * timescale);
    c += Strand(fragCoord, vec3(1.0, 0.0, 1.0), 0.84525 + 1.0 + sin(time) * 30.0, 1.2, 0.18, 9.0 * timescale);
    //c += clamp(Muzzle(fragCoord, timescale), 0.0, 1.0);

    // Calculate alpha based on color intensity
    float alpha = clamp(length(c) / 1.732, 0.0, 1.0); // 1.732 is sqrt(3), max possible length for normalized RGB

	fragColor = vec4(c.r, c.g, c.b, alpha);
}
