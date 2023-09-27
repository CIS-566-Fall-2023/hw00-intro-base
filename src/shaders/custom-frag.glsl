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

uniform vec4 u_Color;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

float random(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 54.53))) * 43758.5453);
}

float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float perlin(vec3 P) {
    vec3 Pi = floor(P);
    vec3 Pf = P - Pi;
    vec3 w = vec3(fade(Pf.x), fade(Pf.y), fade(Pf.z));

    float a = random(Pi);
    float b = random(Pi + vec3(1.0, 0.0, 0.0));
    float c = random(Pi + vec3(0.0, 1.0, 0.0));
    float d = random(Pi + vec3(1.0, 1.0, 0.0));

    float e = random(Pi + vec3(0.0, 0.0, 1.0));
    float f = random(Pi + vec3(1.0, 0.0, 1.0));
    float g = random(Pi + vec3(0.0, 1.0, 1.0));
    float h = random(Pi + vec3(1.0, 1.0, 1.0));

    float u = mix(a, b, w.x);
    float v = mix(c, d, w.x);
    float m = mix(u, v, w.y);

    float i = mix(e, f, w.x);
    float j = mix(g, h, w.x);
    float n = mix(i, j, w.y);

    float result = mix(m, n, w.z);
    return result;
}

void main() {
    vec4 diffuseColor = u_Color;
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;

    float noiseValueR = perlin(fs_Pos.xyz * 5.0); // Scale for detail
    float noiseValueG = perlin(fs_Pos.xyz * 5.0 + 5.0);
    float noiseValueB = perlin(fs_Pos.xyz * 3.0 + 1.0);

    // Combine 3D Perlin noise with Lambert shading*/
    float red = diffuseColor.r * lightIntensity * noiseValueR;
    float green = diffuseColor.g * lightIntensity * noiseValueG;
    float blue = diffuseColor.b * lightIntensity * noiseValueB;

    out_Col = vec4(red, green, blue, diffuseColor.a);
}