// modified from : https://www.shadertoy.com/view/XtBXW3
// modified by: @zeyus
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float time;
uniform float angle;

out vec4 fragColor;

// TODO: make this a uniform...
vec2 targetSize = uSize / 2.0;

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
    float glow = 0.06 * targetSize.y;
    float twopi = 6.28318530718;
    float curve = 1.0 - abs(fragCoord.y - (sin(mod(fragCoord.x * hscale / 100.0 / targetSize.x * 1000.0 + time * timescale + hoffset, twopi)) * targetSize.y * 0.25 * vscale + targetSize.y / 2.0));
    float i = clamp(curve, 0.0, 1.0);
    i += clamp((glow + curve) / glow, 0.0, 1.0) * 0.4 ;
    return i * color;
}

vec3 Muzzle(in vec2 fragCoord, in float timescale)
{
    float theta = atan(targetSize.y / 2.0 - fragCoord.y, targetSize.x - fragCoord.x + 0.13 * targetSize.x);
	float len = targetSize.y * (10.0 + sin(theta * 20.0 + float(int(time * 20.0)) * -35.0)) / 11.0;
    float d = max(-0.6, 1.0 - (sqrt(pow(abs(targetSize.x - fragCoord.x), 2.0) + pow(abs(targetSize.y / 2.0 - ((fragCoord.y - targetSize.y / 2.0) * 4.0 + targetSize.y / 2.0)), 2.0)) / len));
    return vec3(d * (1.0 + sin(theta * 10.0 + floor(time * 20.0) * 10.77) * 0.5), d * (1.0 + -cos(theta * 8.0 - floor(time * 20.0) * 8.77) * 0.5), d * (1.0 + -sin(theta * 6.0 - floor(time * 20.0) * 134.77) * 0.5));
}

void main()
{
    vec2 fragCoord = FlutterFragCoord();
    
    
    // Center the coordinates to rotate around the center
    vec2 center = uSize / 2.0;

    float scaleX = targetSize.x / uSize.x;
    float scaleY = targetSize.y / uSize.y;

    vec2 centered = fragCoord - center;
    vec2 scaled = vec2(centered.x * scaleX, centered.y * scaleY);

    
    // Rotate the centered coordinates
    vec2 rotated = rotate(scaled, angle);
    
    if(abs(rotated.x) > targetSize.x / 2.0 || abs(rotated.y) > targetSize.y / 2.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }
    
    vec2 finalCoord = vec2(
        rotated.x + targetSize.x / 2.0,
        rotated.y + targetSize.y / 2.0
    );

    float timescale = 1.0;
	vec3 c = vec3(0, 0, 0);
    c += Strand(finalCoord, vec3(1.0, 0, 0), 0.7934 + 1.0 + sin(time) * 30.0, 1.0, 0.16, 10.0 * timescale);
    c += Strand(finalCoord, vec3(0.0, 1.0, 0.0), 0.645 + 1.0 + sin(time) * 30.0, 1.5, 0.2, 10.3 * timescale);
    c += Strand(finalCoord, vec3(0.0, 0.0, 1.0), 0.735 + 1.0 + sin(time) * 30.0, 1.3, 0.19, 8.0 * timescale);
    c += Strand(finalCoord, vec3(1.0, 1.0, 0.0), 0.9245 + 1.0 + sin(time) * 30.0, 1.6, 0.14, 12.0 * timescale);
    c += Strand(finalCoord, vec3(0.0, 1.0, 1.0), 0.7234 + 1.0 + sin(time) * 30.0, 1.9, 0.23, 14.0 * timescale);
    c += Strand(finalCoord, vec3(1.0, 0.0, 1.0), 0.84525 + 1.0 + sin(time) * 30.0, 1.2, 0.18, 9.0 * timescale);
    c += clamp(Muzzle(finalCoord, timescale), 0.0, 1.0);

	fragColor = vec4(c.r, c.g, c.b, 1.0);
}
