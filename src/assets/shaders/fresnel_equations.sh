// Fast smooth at high incidence, almost linear at low incidence
float fresnel_fast(float cos_theta_incident, float cos_critical, float refractive_ratio)
{
	return pow(1.0 - max(cos_theta_incident, cos_critical), refractive_ratio);
}

//Fast smooth at low incidence, almost linear at high incidence
float fresnel_fast_2(float cos_theta_incident, float cos_critical, float refractive_ratio)
{
	return 1.0 - pow(max(cos_theta_incident, cos_critical), 1.0 / refractive_ratio);
}

/*
 *	Fresnel reflection using Fresnel equations
 *
 *	@param cos_theta_incident	Dot product of incident vector and normal
 *	@param cos_critical			Cosine of critical angle, [0, 1]
 *	@param refractive_ratio		Ratio of refractive-indices, ior2/ior1
 */
float compute_fresnel(float cos_theta_incident, float cos_critical, float refractive_ratio) {
	if (cos_theta_incident <= cos_critical)
		return 1.f;
	float rr = max(1.0, refractive_ratio);
	float sin_theta_incident2 = 1.f - cos_theta_incident*cos_theta_incident;
	float t = sqrt(1.f - sin_theta_incident2 / (rr * rr));
	float sqrtRs = (cos_theta_incident - rr * t) / (cos_theta_incident + rr * t);
	float sqrtRp = (t - rr * cos_theta_incident) / (t + rr * cos_theta_incident);

	return mix(sqrtRs * sqrtRs, sqrtRp * sqrtRp, .5f);
}