#version 300 es

precision highp float;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

uniform vec4 u_Color;
uniform float u_Time;

out vec4 out_Col;

// Simple Perlin noise function
float perlin(vec3 p) {
    return fract(sin(dot(p, vec3(12.9, 78.2, 98.42))) * 43758.54);
}

void main() {
    // Create a noise pattern based on the fragment's 3D position and time
    float noiseValue = perlin(vec3(20, 24, sin(u_Time * 0.001)));

    // Use the noise value to modify the color
    vec3 modifiedColor = fs_Col.rgb + vec3(noiseValue * 0.2);

    // Calculate diffuse lighting
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

    // Combine the modified color with lighting
    vec3 finalColor = modifiedColor * diffuseTerm + vec3(0.1); // Add ambient light

    out_Col = vec4(finalColor, 1.0);
}
