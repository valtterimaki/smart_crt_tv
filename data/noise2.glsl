
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
//#define PROCESSING_COLOR_SHADER

uniform sampler2D texture;
uniform vec2 resolution;

uniform float time;
uniform float amount1;
uniform float amount2;
uniform float spikiness1;
uniform float spikiness2;

float rand1(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void)
{

  // Get the UV Coordinate of your texture or Screen Texture, yo!
  vec2 uv = gl_FragCoord.xy / resolution.xy;

  // Flip that shit, cause shadertool be all "yolo opengl"
  uv.y = -1.0 - uv.y;

  //scroll effect
  uv.y += time;

  // special effect WORK ON THIS
  uv.x = uv.x + (sin(uv.y * 10 + time*3) / 10);
  uv.x = uv.x + (sin(uv.y * 19 + time*27) / 8);
  uv.x = uv.x + (sin(uv.y * 27 + time*13) / 10) - pow(rand1(vec2(uv.x/100, time)), 10) * amount1;

  //uv.y -= pow(rand1(vec2(uv.x/100, time)), 10) * amount1;

  // Get the pixel color at the index.
  vec3 color = texture2D(texture, uv).xyz;

  gl_FragColor = vec4(color, 1.0);
}

