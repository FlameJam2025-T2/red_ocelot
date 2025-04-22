precision mediump float;

layout(location = 0) out vec4 fragColor;

uniform float u_time;
uniform float u_temperature;

// Cheap hash-based noise
float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
  vec2 uv = gl_FragCoord.xy / vec2(1000.0, 600.0); // For full dynamic use, pass as uniform

  // Shimmer wave
  float wave = sin((uv.x + u_time) * 20.0) * 0.03;
  float shimmer = wave + sin((uv.y + u_time) * 10.0) * 0.03;

  // Random flicker
  float flicker = random(vec2(floor(uv.x * 10.0), floor(u_time * 10.0))) * 0.25;

  // Edge glow
  float edgeGlow = smoothstep(0.0, 0.3, uv.x) * smoothstep(1.0, 0.7, uv.x);
  edgeGlow *= smoothstep(0.0, 0.2, uv.y);

  // Horizontal color variation
  vec3 cool = vec3(0.2 + uv.x * 0.05, 0.4 + uv.x * 0.05, 1.0);
  vec3 hot = vec3(1.0, 0.2 + uv.x * 0.05, 0.0);
  vec3 baseColor = mix(cool, hot, u_temperature);

  // Combine everything
  vec3 finalColor = baseColor
    + shimmer * u_temperature * 0.3
    + flicker * u_temperature
    + edgeGlow * u_temperature * 0.4;

  fragColor = vec4(finalColor, 1.0);
}