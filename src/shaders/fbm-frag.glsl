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
                  // screen for the pixel that is currently being processed.

float noise(vec4 seed) {
    return fract(sin(dot(seed, vec4(324.223, 56.23, 234.354, 6543.0))) * 9834517.23489);
}

float fbm() {
    float total = 0.0f;
    float pers = 1.0f / 2.0f;
    float octaves = 5.0f;

    for (float i = 0.0f; i < octaves; i++) {
        float freq = pow(2.0f, i);
        float amp = pow(pers, i);

        total += amp * noise(fs_Pos * freq);
    }
    return total;
    //return total/octaves;
}

void main()
{
    // Material base color (before shading)
    vec4 complement = vec4(1.0f) - u_Color;
    complement[3] = 1.0f;
    float noise = fbm();
    float fade = fract(6.0f * pow(noise, 5.0f) - 15.0f * pow(noise, 4.0f) + 10.0f * pow(noise, 3.0f));
    vec4 diffuseColor = mix(u_Color, complement, fade); //u_Color;

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
