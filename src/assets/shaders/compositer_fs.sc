$input v_texcoord0

#include <bgfx_shader.sh>

#if BGFX_SHADER_LANGUAGE_GLSL
#define ZBUFMIN 0.0
#define ZBUFMAX 1.0
#else
#define ZBUFMIN -1.0
#define ZBUFMAX 1.0
#endif


uniform vec4 color;
uniform vec4 fade;
uniform vec4 uClock;
uniform vec4 uZFrustum; // z_near, z_far, fov, ___
SAMPLER2D(s_tex, 0); // main framebuffer
SAMPLER2D(s_depth, 1);
SAMPLER2D(b_tex, 2); // framebuffer for "bubbles fx"
SAMPLER2D(b_depth, 3);

#define WAV_FREQ_X 15.0
#define WAV_FREQ_Y 6.0
#define PI 3.141592653589793

#define BLUR_RAD 0.0025
#define MAX_BLUR_SAMPLE 4

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float get_zFromDepth(float zDepth)
{
	float a, b;
	const float zb_amplitude = ZBUFMAX - ZBUFMIN;
	a = uZFrustum.y / (uZFrustum.y - uZFrustum.x * zb_amplitude);
	b = uZFrustum.y * uZFrustum.x * zb_amplitude / (uZFrustum.x * zb_amplitude - uZFrustum.y);
	return b / (zDepth * zb_amplitude + ZBUFMIN-a) / uZFrustum.z;
}

void main() {
	// fix UV orientation
	// vec2 UV0 = vec2(1.0, 0.0) + vec2(-1.0, 1.0) * v_texcoord0;

#if BGFX_SHADER_LANGUAGE_GLSL
	vec2 UV0 = vec2(1.0, 1.0) + vec2(-1.0, -1.0) * v_texcoord0;
#else
	vec2 UV0 = vec2(1.0, 0.0) + vec2(-1.0, 1.0) * v_texcoord0;
#endif

	// fake vignette (only affects the border of the image)
	float vignette = mix(clamp(map(UV0.x, 0.0, 0.25, 0.0, 1.0), 0.0, 1.0), clamp(map(UV0.x, 0.0, 0.25, 0.0, 1.0), 0.75, 1.0), UV0.y);
	vignette *= clamp(map(UV0.x, 0.75, 1.0, 1.0, 0.0), 0.0, 1.0);
	vignette *= clamp(map(UV0.y, 0.0, 0.25, 0.0, 1.0), 0.0, 1.0);
	vignette *= mix(clamp(map(UV0.y, 0.75, 1.0, 1.0, 0.0), 0.75, 1.0), clamp(map(UV0.y, 0.75, 1.0, 1.0, 0.0), 0.0, 1.0), UV0.x);
	float inv_vignette = ((1.0 - vignette) * 5.0) + 1.0;

	// get bubble masked by landscape
	float i, j, z;
	vec2 o;
	// float z_bg = 0.0, z_bubbles = 0.0;
	for(j = 0; j < MAX_BLUR_SAMPLE; j++)
	{
			for(i = 0; i < MAX_BLUR_SAMPLE; i++)
			{
				o = vec2(i - (MAX_BLUR_SAMPLE / 2.0), j - (MAX_BLUR_SAMPLE / 2.0)) * vec2(BLUR_RAD * 0.5, BLUR_RAD) * 0.25;
				float z_bg = get_zFromDepth(texture2D(s_depth, UV0 + o).x);
				float z_bubbles = get_zFromDepth(texture2D(b_depth, UV0 + o).x);
				z += 1.0 - clamp(z_bubbles - z_bg, 0.0, 1.0);
			}
	}
	z /= (MAX_BLUR_SAMPLE * MAX_BLUR_SAMPLE);

	// 0.0 to 1.0 factor to exclude the walkman from the blur
	float zb = clamp(1.0 - (get_zFromDepth(texture2D(s_depth, UV0).x) * 0.001), 0.0, 1.0);
	zb = clamp(map(zb, 0.97, 0.97225, 0.0, 1.0), 0.0, 1.0);

	vignette = clamp(vignette + zb, 0.0, 1.0);

	// distort buffer along a wavy fx
	vec2 waveUV0;

	waveUV0.x = 0.5 * sin((UV0.x + uClock.x * 0.175) * WAV_FREQ_X + sin((UV0.y + uClock.x) * 2.5));
	waveUV0.y = 0.5 * cos((UV0.y + uClock.x * 0.35) * WAV_FREQ_Y + cos((PI * 0.1245 + (UV0.x + uClock.x * 0.25)) * 15.0));
#if 1
	waveUV0.x = mix(waveUV0.x, sin(waveUV0.x * 3.0), 0.5);
	waveUV0.y = mix(waveUV0.y, cos(waveUV0.y * 4.0), 0.5);

	// waveUV0.x = mod(waveUV0.x + 4.0 * pow(waveUV0.x, 4.0), 1.0);
	// waveUV0.y = mod(waveUV0.x + 4.0 * pow(waveUV0.y, 4.0), 1.0);

	waveUV0.x = waveUV0.x - 4.0 * pow((waveUV0.x + 1.0) * 0.5, 4.0);
	waveUV0.y = waveUV0.x - 4.0 * pow((waveUV0.y + 1.0) * 0.5, 4.0);

#endif
	float overscan = clamp(map(UV0.x, 0.0, 0.05, 0.0, 1.0), 0.0, 1.0);
	overscan *= clamp(map(UV0.x, 0.95, 1.0, 1.0, 0.0), 0.0, 1.0);
	overscan *= clamp(map(UV0.y, 0.0, 0.1, 0.0, 1.0), 0.0, 1.0);
	overscan *= clamp(map(UV0.y, 0.9, 1.0, 1.0, 0.0), 0.0, 1.0);
	waveUV0 = waveUV0 * vec2(0.01 * overscan * uClock.y, 0.01 * overscan * uClock.y);

	// distort buffer along the bubbles
#if 0
	vec3 bubble_rgb = texture2D(b_tex, UV0).xyz;
#else
	vec3 bubble_rgb = vec3(0.0, 0.0, 0.0);
	for(j = 0; j < MAX_BLUR_SAMPLE; j++)
	{
			for(i = 0; i < MAX_BLUR_SAMPLE; i++)
			{
				o = vec2(i - (MAX_BLUR_SAMPLE / 2.0), j - (MAX_BLUR_SAMPLE / 2.0)) * vec2(BLUR_RAD * 0.5, BLUR_RAD) * 0.25 * inv_vignette;
				bubble_rgb += texture2D(b_tex, UV0 + o).xyz;
			}
	}
	bubble_rgb /= (MAX_BLUR_SAMPLE * MAX_BLUR_SAMPLE);
#endif
	vec2 bubbleUV0 = (vec2(bubble_rgb.x, bubble_rgb.y) - vec2(0.5, 0.5)) * 2.0 * 0.015 * z;
	// vec2 bubbleUV0 = (vec2(bubble_rgb.x, bubble_rgb.y)) * 2.0 * 0.015 * z;

	// poorman's color dispersion
	float dispersion = mix(clamp(map(UV0.x, 0.0, 0.5, 0.0, 1.0), 0.0, 1.0), clamp(map(UV0.x, 0.0, 0.5, 0.5, 1.0), 0.0, 1.0), UV0.y);
	dispersion *= clamp(map(UV0.x, 0.5, 1.0, 1.0, 0.0), 0.0, 1.0);
	dispersion *= clamp(map(UV0.y, 0.0, 0.25, 0.5, 1.0), 0.5, 1.0);
	dispersion *= mix(clamp(map(UV0.y, 0.75, 1.0, 1.0, 0.75), 0.5, 1.0), clamp(map(UV0.y, 0.75, 1.0, 1.0, 0.5), 0.5, 1.0), UV0.x);
	dispersion = 1.0 - dispersion;
	dispersion = pow(dispersion, 2.0);
	dispersion *= 0.005;

	// the wavy fx will impact the color dispersion (a bit)
	dispersion += waveUV0.x * 0.1;

	float r = 0, g = 0, b = 0;
	vec2 bo; // blur UV offset
	// float i, j;

	// Box blur on vignette
	for(j = 0; j < MAX_BLUR_SAMPLE; j++)
	{
		bo.y = (j - (MAX_BLUR_SAMPLE * 0.5)) * BLUR_RAD * 2.0 * (1.0 - vignette);
		for(i = 0; i < MAX_BLUR_SAMPLE; i++)
		{
			bo.x = (i - (MAX_BLUR_SAMPLE * 0.5)) * BLUR_RAD * (1.0 - vignette);

			r += texture2D(s_tex, clamp(UV0 + bo + waveUV0 + bubbleUV0 - vec2(dispersion, 0.0), 0.0, 1.0)).x;
			g += texture2D(s_tex, clamp(UV0 + bo + waveUV0 + bubbleUV0 + vec2(dispersion, 0.0), 0.0, 1.0)).y;
			b += texture2D(s_tex, UV0 + bo + waveUV0 + bubbleUV0).z;
		}
	}
	r *= (1.0 / (MAX_BLUR_SAMPLE * MAX_BLUR_SAMPLE));
	g *= (1.0 / (MAX_BLUR_SAMPLE * MAX_BLUR_SAMPLE));
	b *= (1.0 / (MAX_BLUR_SAMPLE * MAX_BLUR_SAMPLE));

	// Bubble (fake fresnel) edges
	float bubble_edges = pow(bubble_rgb.z, 4.0) * 0.75 * z; // * vignette;

	r *= (1.0 - bubble_edges);
	g *= (1.0 - bubble_edges);
	b *= (1.0 - bubble_edges);

	// Bubble reflections
	vec3 refl = texture2D(s_tex, UV0 + bubble_rgb.xy * 1.5).xyz;
	refl *= z;
	refl *= bubble_rgb.z;
	r += refl.x;
	g += refl.y;
	b += refl.z;

	r = r * fade.x;
	g = g * fade.x;
	b = b * fade.x;

	r = pow(r, fade.y);
	g = pow(g, fade.y);
	b = pow(b, fade.y);

	gl_FragColor = vec4(r, g, b, 1.0);

	// debug outputs
	// gl_FragColor = vec4(UV0.x + waveUV0.x, UV0.y + waveUV0.y, 0.0, 1.0);
	// gl_FragColor = vec4(dispersion, dispersion, dispersion, 1.0);
	// gl_FragColor = vec4(vignette, vignette, vignette, 1.0);
	// gl_FragColor = vec4(refl, 1.0);
	// gl_FragColor = texture2D(s_tex, UV0);
	// gl_FragColor = texture2D(s_tex, UV0) + texture2D(b_tex, UV0);
	// gl_FragColor = texture2D(b_tex, UV0);
	// gl_FragColor = vec4(z, z, z, 1.0);
	// gl_FragColor = vec4(zb, zb, zb, 1.0);
	// gl_FragColor = vec4(bubble_rgb.x, bubble_rgb.y, bubble_rgb.z, 1.0);
	// gl_FragColor = vec4(bubbleUV0 * 200.0, 0.0, 1.0);
}

