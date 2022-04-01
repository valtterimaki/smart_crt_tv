
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
  //uv.y = -1.0 - uv.y;
  // special effect WORK ON THIS
  uv.y = -1.0 - uv.y + (sin(uv.x * 1000 + time/2) / 50000);

  // Modify that X coordinate by the sin of y to oscillate back and forth up in this.
  //uv.x += (sin(uv.y * 10.0 + time/2) / 100.0 * (glitch / 8));
  //uv.x += ((rand1(uv)+time)/100);
  //uv.x -= rand1(vec2(uv.y, time)) / (rand1(vec2(time, 30))*rand1(vec2(73, time*1.77))*50+100);
  uv.x -= pow(rand1(vec2(uv.y, time)), spikiness1) * amount1;
  if (amount2 != 0) {
    uv.x -= pow(rand1(vec2(uv.y, time * 7.8)), 10) * amount2;
  }


  // Get the pixel color at the index.
  vec3 color = texture2D(texture, uv).xyz;

  gl_FragColor = vec4(color, 1.0);
}

