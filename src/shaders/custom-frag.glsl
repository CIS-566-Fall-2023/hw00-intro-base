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
in vec4 fs_LightVec;
in vec4 fs_Col;

in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 random3(vec3 p) {
    return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 513.3)),
                          dot(p, vec3(269.5, 183.3, 419.2)),
                          dot(p, vec3(420.6, 631.2, 937.3))
                    )) * 43758.5453);
}

float surflet(vec3 P, vec3 gridPoint) {
    // Compute falloff function by converting linear distance to a polynomial
    vec3 dist = abs(P - gridPoint);
    vec3 t = 1.0 - 6.0 * dist * dist * dist * dist * dist
                     + 15.0 * dist * dist * dist * dist
                     - 10.0 * dist * dist * dist;
    
    // Get the random vector for the grid point
    vec3 gradient = 2.0 * random3(gridPoint) - vec3(1.0);
    
    // Get the vector from the grid point to P
    vec3 diff = P - gridPoint;
    
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
}

float perlinNoise(vec3 uvw) {
    float surfletSum = 0.0;
    
    // Iterate over the eight integer corners surrounding uvw
    for (int dx = 0; dx <= 1; ++dx) {
        for (int dy = 0; dy <= 1; ++dy) {
            for (int dz = 0; dz <= 1; ++dz) {
                // Construct the grid point in 3D
                vec3 gridPoint = floor(uvw) + vec3(dx, dy, dz);
                
                // Calculate the surflet contribution for this grid point
                surfletSum += surflet(uvw, gridPoint);
            }
        }
    }
    
    return surfletSum;
}



void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        float perlinValue = 1.0 - perlinNoise(vec3(fs_Pos)/0.3);
        

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.


        diffuseColor *=perlinValue;

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
