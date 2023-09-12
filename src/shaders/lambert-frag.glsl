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

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// Hash function to create gradients for Perlin noise
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Linear interpolation function
float lerp(float a, float b, float t) {
    return mix(a, b, t);
}

// Perlin noise function
float perlin(vec2 P) {
    // Grid cell coordinates
    vec2 Pi = floor(P);
    vec2 Pf = fract(P);

    // Eight surrounding gradients
    vec2 gradient1 = vec2(hash(Pi.x + Pi.y * 57.0), hash(Pi.x + Pi.y * 57.0 + 1.0));
    vec2 gradient2 = vec2(hash(Pi.x + 1.0 + Pi.y * 57.0), hash(Pi.x + 1.0 + Pi.y * 57.0 + 1.0));

    // Smooth the position within the cell
    vec2 fade = smoothstep(0.0, 1.0, Pf);

    // Interpolate gradients
    float dot1 = dot(gradient1, Pf - vec2(0.0, 0.0));
    float dot2 = dot(gradient2, Pf - vec2(1.0, 0.0));
    float lerp1 = lerp(dot1, dot2, fade.x);

    // Interpolate along the y-axis
    float dot3 = dot(gradient1, Pf - vec2(0.0, 1.0));
    float dot4 = dot(gradient2, Pf - vec2(1.0, 1.0));
    float lerp2 = lerp(dot3, dot4, fade.x);

    // Interpolate along the z-axis
    return lerp(lerp1, lerp2, fade.y) * 0.5 + 0.5;
}

void main() {
    // Material base color (before shading)
    vec4 diffuseColor = u_Color;

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    // diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;

    // Generate Perlin noise at the current fragment's screen coordinates
    float noiseValue = perlin(fs_Nor.xy); // Adjust the scale as needed

    // Modify the diffuseColor based on the noiseValue
    // You can adjust the factor by which the noise affects the color
    float noiseFactor = 0.2;
    diffuseColor.rgb += noiseValue * noiseFactor;

    // Clamp color values to the [0, 1] range
    diffuseColor.rgb = clamp(diffuseColor.rgb, 0.0, 1.0);

    // Compute the final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}