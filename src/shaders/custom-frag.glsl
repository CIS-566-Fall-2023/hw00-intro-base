#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_Col;
in vec4 fs_Pos; 

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 
vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

// pow function for vec3 
vec3 pow3(vec3 v, float f) {
    float v1 = pow(v[0], f);
    float v2 = pow(v[1], f);
    float v3 = pow(v[2], f); 
    vec3 toReturn = vec3(v1, v2, v3); 
    return toReturn; 
}

// surflets for noise 
// surflets = dot prod relative to vectors anchored at regular points within a domain
float surflet(vec3 p, vec3 gridPoint) {
    // Compute the distance between p and the grid point along each axis, and warp it with a
    // quintic function so we can smooth our cells
    vec3 t2 = abs(p - gridPoint);
    vec3 t = vec3(1.f) - 6.f * pow3(t2, 5.f) + 15.f * pow3(t2, 4.f) - 10.f * pow3(t2, 3.f);
    // Get the random vector for the grid point (assume we wrote a function random2
    // that returns a vec2 in the range [0, 1])
    vec3 gradient = random3(gridPoint) * 2. - vec3(1., 1., 1.);
    // Get the vector from the grid point to P
    vec3 diff = p - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
}

// 3D perlin noise  
float perlinNoise3D(vec3 p) {
	float surfletSum = 0.f;
    // multiply by large number to make more fuzzy/static looking 
    // p = p * 5.f;
    p = p * 4.f;
	// Iterate over the four integer corners surrounding uv
	for(int dx = 0; dx <= 1; ++dx) {
		for(int dy = 0; dy <= 1; ++dy) {
			for(int dz = 0; dz <= 1; ++dz) {
                // sum up surflets
				surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
			}
		}
	}
	return surfletSum;
}

void main()
{
    // Material base color (before shading)
    vec4 diffuseColor = u_Color;
    
    // Perlin noise 
    float noise = perlinNoise3D(vec3(fs_Pos)) * 10.f; 
    
    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * noise, diffuseColor.a);
}
