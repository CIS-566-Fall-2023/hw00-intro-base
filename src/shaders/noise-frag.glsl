#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your

vec3 random3(vec3 gridpoint) {
    // returns a vec3 in the range [0, 1]
    float x = gridpoint.x;
    x = (1.0 - (x * (x * x * 15731.0 + 789221.0) + 1376312589.0)) / 10737741824.0;
    float y = gridpoint.y;
    y = (7.0 - (y * y * y * 7907.0 + 26317.0)) / 0.1123422 * 11002549.0;
    float z = gridpoint.z;
    z = (2000004023.0 - (z * (1.0 - z) * z + 500713.0) / 75759451.0);
    return vec3(x,y,z);
}

float surflet(vec3 p, vec3 gridPoint) {
    // Compute the distance between p and the grid point along each axis, and warp it with a
    // quintic function so we can smooth our cells
    vec3 t2 = abs(p - gridPoint);
    vec3 t = vec3(1) - 6.0 * pow(t2, vec3(5)) + 15.0 * pow(t2, vec3(4)) - 10.0 * pow(t2, vec3(3));
    
    // Get the random vector for the grid point 
    vec3 gradient = random3(gridPoint) * 2.0 - vec3(1, 1, 1);
    
    // Get the vector from the grid point to P
    vec3 diff = p - gridPoint;
    
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
}

float perlinNoise3D(vec3 p) {
	float surfletSum = 0.0;
	// Iterate over the four integer corners surrounding uv
	for(int dx = 0; dx <= 1; ++dx) {
		for(int dy = 0; dy <= 1; ++dy) {
			for(int dz = 0; dz <= 1; ++dz) {
				surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
			}
		}
	}
	return surfletSum;
}

void main()
{
    //float v = perlinNoise3D(vs_Pos.xyz);
        // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
