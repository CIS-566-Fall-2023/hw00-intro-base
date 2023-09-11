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

uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 powVec3(vec3 v, int p)
{
    for (int i = 0; i < p; i++)
    {
        v *= v;
    }
    return v;
}

vec3 random3(vec3 p)
{
    float x = fract(sin(dot(p, vec3(127.1, 311.7, 275.2))) * 43758.5453);
    float y = fract(sin(dot(p, vec3(269.5, 183.3, 167.7))) * 43758.5453);
    float z = fract(sin(dot(p, vec3(420.6, 631.2, 728.1))) * 43758.5453);
    return vec3(x, y, z);
}


float surflet(vec3 p, vec3 gridPoint)
{
    vec3 t2 = abs(p - gridPoint);
    vec3 t = vec3(1.f) - 6.f * powVec3(t2, 5) + 15.f * powVec3(t2, 4) - 10.f * powVec3(t2, 3);
    vec3 gradient = random3(gridPoint) * 2.f - vec3(1.f, 1.f, 1.f);
    vec3 diff = p - gridPoint;

    float height = dot(diff, gradient);

    return height * t.x * t.y * t.z;
}

float perlinNoise3D(vec3 p)
{
    float surfletSum = 0.f;
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
    float a = perlinNoise3D(vec3(fs_Pos[0], fs_Pos[1], fs_Pos[2]));

    out_Col = vec4(a, a, a, 1);
}
