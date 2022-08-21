$input vWorldPos, vModelPos, vNormal, vModelNormal, vTangent, vBinormal, vTexCoord0, vTexCoord1, vLinearShadowCoord0, vLinearShadowCoord1, vLinearShadowCoord2, vLinearShadowCoord3, vSpotShadowCoord, vProjPos, vPrevProjPos

#include <forward_pipeline.sh>
#include <fresnel_equations.sh>

// Surface attributes
uniform vec4 uDiffuseColor;
uniform vec4 uSpecularColor;
uniform vec4 uSelfColor;
uniform vec4 uMatAttribute;

// Texture slots
SAMPLER2D(uLightMap, 3);
SAMPLER2D(uReflectionMap, 7);

float remap(float value, float low1, float high1, float low2, float high2) {
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

// Entry point of the forward pipeline default uber shader (Phong and PBR)
void main() {
	vec3 color = uDiffuseColor.xyz;

	vec3 view = mul(u_view, vec4(vWorldPos, 1.0)).xyz;
	vec3 P = vWorldPos; // fragment world pos
	vec3 V = normalize(GetT(u_invView) - P); // view vector
	vec3 N = sign(dot(V,vNormal)) * normalize(vNormal); // geometry normal
	vec3 R = reflect(-V, N); // view reflection vector around normal
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	
	// Fresnel values
	float fake_fresnel = pow(NdotV, 2.0); // remap(fake_fresnel, 0.0, 0.5, 1.0, 0.0);
	color = vec3(fake_fresnel, fake_fresnel, fake_fresnel);
	color *= texture2D(uLightMap, vTexCoord0).xyz;

	color *= uDiffuseColor.xzy;

	color = pow(color, vec3(1.5, 1.5, 1.5)) * 1.5 * uDiffuseColor.w;

	gl_FragColor = vec4(color, uDiffuseColor.w);
}
