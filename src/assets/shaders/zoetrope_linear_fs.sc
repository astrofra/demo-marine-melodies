$input vWorldPos, vNormal, vTexCoord0, vTexCoord1, vTangent, vBinormal

#include <forward_pipeline.sh>

// Surface attributes
uniform vec4 uDiffuseColor;
uniform vec4 uSelfColor;
uniform vec4 uParam;

// Texture slots
SAMPLER2D(uDiffuseMap, 0);

float remap(float value, float low1, float high1, float low2, float high2) {
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

// Entry point of the forward pipeline default uber shader (Phong and PBR)
void main() {
	vec3 view = mul(u_view, vec4(vWorldPos,1.0)).xyz; // fragment view space pos
	vec3 P = vWorldPos; // fragment world pos
	vec3 V = normalize(GetT(u_invView) - P); // view vector
	vec3 N = normalize(vNormal); // geometry normal

	float uv_offset = remap(floor(uParam.x), 0.0, (uParam.y - 1.0), 0.0, 1.0 - (1.0 / uParam.y));
	vec4 diffuse_rgba = texture2D(uDiffuseMap, vTexCoord0 * vec2(1.0 / uParam.y, 1.0) + vec2(uv_offset,0.0));
	diffuse_rgba *= uDiffuseColor;

	// if (opacity_map.x * diffuse_rgba.w < 0.5)
	// 	discard;
	gl_FragColor = diffuse_rgba;
}
