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

vec3 power(vec3 v, float power)
{
    for (float i = 0.0; i < power; i += 1.0) {
       v *= v;
    }
    return v;
}

vec3 noise3DVec(vec3 v)
{
    v += 0.1;
    vec3 noise = sin(vec3(dot(v, vec3(127.1, 311.7, 150.0)),
                          dot(v, vec3(420.2, 631.2, 10.0)),
                          dot(v, vec3(320.2, 31.2, 50.0))));
    noise[0] *= 444.5453;
    noise[1] *= 133334.1453;
    noise[2] *= 7777.8453;
    return normalize(abs(fract(noise)));
}

float surflet3D(vec3 p, vec3 gridPoint)
{
    vec3 t2 = abs(p - gridPoint);
    vec3 t = vec3(1.0) - 6.0 * power(t2, 5.0) + 15.0 * power(t2, 4.0) - 10.0 * power(t2, 3.0);
    vec3 gradient = noise3DVec(gridPoint) * 2.0 - vec3(1.0, 1.0, 1.0);
    vec3 diff = p - gridPoint;
    float height = dot(diff, gradient);
    return height * t.x * t.y * t.z;
}

float perlinNoise3D(vec3 p)
{
    float surfletSum = 0.0;
    // Iterate over the four integer corners surrounding uv
    for(int dx = 0; dx <= 1; ++dx) {
        for(int dy = 0; dy <= 1; ++dy) {
            for(int dz = 0; dz <= 1; ++dz) {
                vec3 gridPoint = floor(p) + vec3(float(dx), float(dy), float(dz));
                surfletSum += surflet3D(p, gridPoint);
            }
        }
    }
    return surfletSum;
}



void main()
{
    // Material base color (before shading)
    float noise = perlinNoise3D(0.05 * vec3(fs_Pos.x, fs_Pos.y, fs_Pos.z));
    //clamp(noise, 0.0, 1.0);
    vec4 diffuseColor = vec4(u_Color.x + noise, u_Color.y + noise, u_Color.z , u_Color.a);
    //vec4 diffuseColor = u_Color;

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    // diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.5;

    //float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.
    
    float lightIntensity = ambientTerm;
    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
