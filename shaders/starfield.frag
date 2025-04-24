// From; https://www.shadertoy.com/view/7dVGz1
// modified by: @zeyus
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float cumulativeX;
uniform float cumulativeY;
uniform float time;

out vec4 f;

const float scale = 3e4;

#define F for(float i = .1; i <.9; i+=.04)
void main()
{	
    vec2 u = FlutterFragCoord() / uSize.y;
    f -= f;    
    F 
    {
        // Keep the movement mechanics that were working
        vec3 p = vec3(u + vec2(cumulativeX, cumulativeY)/i, i);
        p = abs(1.-mod(p, 2.));
        float a = length(p),
              b,
              c = 0.;
        F
          p = abs(p)/a/a - .74,  // Back to the original value that worked
          b = length(p),
          c += abs(a-b),
          a = b;        
        
        c*=c;
        
        // Simple color: base white with depth-based tinting
        // Blue for distant stars (smaller i)
        // Red for closer stars (larger i)
        vec3 starColor = vec3(1.0);  // Start with white
        starColor.r += i * 1.5 + sin(cumulativeX * 0.2)*0.5;      // Add some red for closer stars
        starColor.b += (1.0-i) * 0.7 + cos(cumulativeY * 0.5)*0.5; // Add some blue for distant stars
        
        // Apply the star color with proper scaling
        f += c * vec4(starColor, 0) / scale;
    }	
}
