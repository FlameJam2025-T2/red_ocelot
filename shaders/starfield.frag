// From; https://www.shadertoy.com/view/7dVGz1
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float cumulativeX; // Renamed from velX
uniform float cumulativeY; // Renamed from velY

out vec4 f;

#define F for(float i = .1; i <.9; i+=.04)
void main()
{	
    vec2 u = FlutterFragCoord() / uSize.y;
    f -= f;    
    F 
    {
        // vec2 on the next line defines direction and speed of the animation
        vec3 p = vec3(u + vec2(cumulativeX, cumulativeY)/i, i);
        p = abs(1.-mod(p, 2.));
        float a = length(p),
              b,
              c = 0.;
        F
          p = abs(p)/a/a - .7,   // <- Kali magic constant (between .5 .. .6 gives good results)
          b = length(p),
          c += abs(a-b),
          a = b;        
        
        c*=c;
                
        f += c*vec4(i, 1, 2, 0) / 3e4 ; // <- overall scaling constant, play here if you're "blind"
    }	
}
