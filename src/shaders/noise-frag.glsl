#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in vec4 fs_CameraPos;

out vec4 out_Col;

vec3 random3(vec3 p3) {
    vec3 p = fract(p3 * vec3(.1031, .11369, .13787));
    p += dot(p, p.xzy + 19.19);
    return -0.5 + 1.5 * fract(vec3((p.x + p.y)*p.z, (p.x+p.z)*p.y, (p.y+p.z)*p.x));
}

float surflet3D(vec3 p, vec3 gridPoint) {
    float t2x = abs(p.x - gridPoint.x);
    float t2y = abs(p.y - gridPoint.y);
    float t2z = abs(p.z - gridPoint.z);
    
    float tx = 1.f - 6.f * pow(t2x, 5.f) + 15.f * pow(t2x, 4.f) - 10.f * pow(t2x, 3.f);
    float ty = 1.f - 6.f * pow(t2y, 5.f) + 15.f * pow(t2y, 4.f) - 10.f * pow(t2y, 3.f);
    float tz = 1.f - 6.f * pow(t2z, 5.f) + 15.f * pow(t2z, 4.f) - 10.f * pow(t2z, 3.f);
    vec3 gradient = random3(gridPoint) * 2.f - vec3(1.f);
    vec3 diff = p - gridPoint;
    float height = dot(diff, gradient);
    return height * tx * ty * tz;
}

float perlinNoise3D(vec3 p) {
	float surfletSum = 0.f;
	// Iterate over the four integer corners surrounding uv
	for(int dx = 0; dx <= 1; ++dx) {
		for(int dy = 0; dy <= 1; ++dy) {
			for(int dz = 0; dz <= 1; ++dz) {
				surfletSum += surflet3D(p, floor(p) + vec3(dx, dy, dz));
			}
		}
	}
	return surfletSum;
}


void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        float perlin = perlinNoise3D(vec3(fs_Pos) * 3.0);

        // Apply perlin.
        diffuseColor *= 1.0 - (abs(perlin) - 0.5);
        diffuseColor += perlinNoise3D(vec3(fs_Pos) * 2.3 * cos(u_Time * 0.001));
        if (perlin <= 0.25) {
            diffuseColor *= cos(perlin) + abs(1.0 - cos(perlin));
        } else {
            diffuseColor *= abs(cos(perlin * 0.1) * 2.0) - abs(1.0 - sin(u_Time * 0.001));
        }
        diffuseColor.a = 1.0;

        // Calculate the diffuse term for Lambert shading

        // Blinn Phuong
        vec4 viewVect = normalize(fs_Pos - fs_CameraPos);
        vec4 lightingVect = normalize(fs_Pos - fs_LightVec);

        vec4 h = (viewVect + lightingVect) / 2.f;

        float specularIntensity = max(pow(dot(h, fs_Nor), 7.f), 0.f);

        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.5;

        float lightIntensity = diffuseTerm + ambientTerm + specularIntensity;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color

        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}