#define SF 2.0

float ssin(float a)
{
	return sin(a * SF);
}

float scos(float a)
{
	return cos(a * SF);
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec3 WaterCaustics(vec3 _P, vec3 _N, float clock)
{
	// Water caustics
	#define WAVES_COLOR vec3(0.1, 0.7, 1.0)

	vec3 Prand = vec3(0.0, 0.0, 0.0);
	vec3 Pt = _P + vec3(clock * 4.0, 0.0, clock * 2.0); // World pos, animated over time
	Prand.x = ssin(_P.x + ssin(Pt.z * 0.1254) + scos(_P.z * 0.25467) + scos((_P.z + 0.5) * 0.38467));
	Prand.y = ssin(_P.y + scos(Pt.z * 0.1254) + scos(_P.x * 0.25467) + ssin((_P.z + 0.5) * 0.38467));
	Prand.z = ssin(_P.z + ssin(Pt.x * 0.1254) + ssin(_P.x * 0.25467) + scos((_P.x + 0.5) * 0.38467));

	Prand.x += ssin(_P.x * 0.2) + ssin(Pt.z * 0.128654);

	Prand.x += ssin(Pt.x * 0.38467) * 0.25;
	Prand.y += ssin(Pt.y * 0.82467) * 0.25;
	Prand.z += ssin(Pt.z * 1.53467) * 0.25;

	Prand.x += scos(Pt.x * 0.8467) * 0.25;
	Prand.y += scos(Pt.y * 0.52467) * 0.25;
	Prand.z += scos(Pt.z * 1.13467) * 0.25;

	vec3 waves = Prand; // vec3(luma, luma, luma);
	float luma = (waves.x + waves.y + waves.z) * 0.3333333;
	luma = ((luma + 4.0) / 8.0);

	// luma *= ((_N.y + 1.0) * 0.5); // simple ligthing against the vertical normal
	float top_f =  clamp(map(_P.y, 10.0, 20.0, 0.0, 1.0), 0.0, 1.0); // more caustics on top of the scene (Y > 15)
	top_f *= top_f;
	luma = mix(luma * ((_N.y + 1.0) * 0.5), luma, top_f);

	// color += vec3(luma, luma, luma) * WAVES_COLOR * occ_rough_metal.x;

	luma = pow(luma, 2.0);
	luma = clamp(map(luma, 0.25, 1.0, 0.0, 0.5), 0.0, 1.0);

	return vec3(luma, luma, luma) * WAVES_COLOR;
}

vec3 SimpleReinhardToneMapping(vec3 color, float exposure) // 1.5
{
	color *= exposure / (1. + color / exposure);
	return color;
}