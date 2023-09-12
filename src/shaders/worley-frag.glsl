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
uniform float u_Time; // The time in seconds since the program started running.
uniform vec4 u_Scale; // Control the scale/frequency of the noise

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const int MAX_POINTS = 8;
const float CELL_SIZE = 0.5;

vec3 random3(vec3 p) {
    return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 231.7)), 
                         dot(p, vec3(269.5, 183.3, 123.3)), 
                         dot(p, vec3(113.5, 301.9, 289.4)))) * 43758.5453);
}

// Calculate the distance to the nearest point in a cube grid
float pointCubeDistance(vec3 p) {
    float d = CELL_SIZE;
    for(int i = 0; i < MAX_POINTS; i++) {
        vec3 offset = random3(p + float(i));
        vec3 diff = p + (CELL_SIZE * offset) - vec3(0.5);
        d = min(d, length(diff));
    }
    return d;
}

// Worley noise function
float worley(vec3 p) {
    p *= u_Scale.xyz;
    float d = CELL_SIZE;
    for(int z = -1; z <= 1; z++) {
        for(int y = -1; y <= 1; y++) {
            for(int x = -1; x <= 1; x++) {
                vec3 cell = vec3(float(x), float(y), float(z));
                d = min(d, pointCubeDistance(p + cell));
            }
        }
    }
    return d/CELL_SIZE;
}

void main()
{
    float noiseValue = worley(fs_Pos.xyz + u_Time);

    // Material base color (before shading)
    vec4 controlledColor = u_Color;
    // color shift
    vec3 black = vec3(0);

    // Compute final shaded color
    out_Col = vec4(vec3(controlledColor - noiseValue), controlledColor.a);
}

