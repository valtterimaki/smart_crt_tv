
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
//#define PROCESSING_COLOR_SHADER

uniform sampler2D texture;
uniform vec2 resolution;

uniform float time;
uniform float amount;

vec2 seed = vec2(102,6574);

float naturalNoise(vec2 p, vec2 seed) {
    return fract(sin (p.x*seed.x+ p.y*seed.y)*5647.);
}

float smoothNoise(vec2 p, vec2 seed) {
    vec2 lv = fract(p);
    vec2 id = floor(p);

    lv = lv*lv*(3.-2.*lv);
    float bl = naturalNoise(id, seed);
    float br = naturalNoise(id + vec2(1,0) , seed);
    float b = mix(bl, br, lv.x);

    float tl = naturalNoise(id+vec2(0,1),seed);
    float tr = naturalNoise(id+vec2(1,1),seed);
    float t = mix(tl, tr, lv.x);

    return mix(b,t,lv.y);
}

float quarticInOut(float t) {
  return t < 0.2
    ? +2.0 * pow(t, 2.0)
    : -8.0 * pow(t - 1.0, 4.0) + 1.0;
}

void main(void)
{

  // Get the UV Coordinate of your texture or Screen Texture, yo!
  vec2 uv = gl_FragCoord.xy / resolution.xy;

  // Flip that shit, cause shadertool be all "yolo opengl"
  uv.y = -1.0 - uv.y;

  // testing using only fractal noise
  uv.x +=
    quarticInOut(smoothNoise(vec2(uv.y*2 + smoothNoise(vec2(time*7, 1), seed), time), seed)) * quarticInOut(amount)
    + (naturalNoise(vec2(uv.y, time), seed) * 0.02) * 0.5
    - 0.07;

  // Other sine effects, saved here for examples
  //uv.x = uv.x + (sin(uv.y * 6 + time*3) / 10);
  //uv.x = uv.x + (sin(uv.y * 19 + time*27) / 80);

  //scroll effect
  uv.y += time/8 + smoothNoise(vec2(time*7, 1), seed) * 0.1;

  // Get the pixel color at the index. Do the magic.
  vec3 color = texture2D(texture, uv).xyz;
  gl_FragColor = vec4(color, 1.0);
}

