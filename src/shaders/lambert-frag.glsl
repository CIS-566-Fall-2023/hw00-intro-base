#version 300 es

#define GAMMA 2.2
#define INV_GAMMA 0.45454545

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

const float LIGHT_INTENSITY = 150.;

vec3 reinhardJodie(vec3 color) {
    float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
    vec3 tColor = color / (vec3(1.) + color);
    return mix(color / (vec3(1.) + luminance), tColor, tColor);
}

vec3 gammaCorrect(vec3 linearColor) {
    return pow(linearColor, vec3(INV_GAMMA));
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // diffuseTerm *= diffuseTerm;
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        // float ambientTerm = 0.2;

        // float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
        //                                                     //to simulate ambient lighting. This ensures that faces that are not
        //                                                     //lit by our point light are not completely black.

        float halfLambert = (diffuseTerm + 1.) * 0.5;
        float lightInvSqIntensity = 1. / dot(vec3(fs_LightVec), vec3(fs_LightVec));

        vec3 finalLinearColor = diffuseColor.rgb * halfLambert * lightInvSqIntensity * LIGHT_INTENSITY;

        // Compute final shaded color
        // out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
        out_Col = vec4(gammaCorrect(reinhardJodie(finalLinearColor)), diffuseColor.a);
}
