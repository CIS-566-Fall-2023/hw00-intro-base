#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

// A simple pseudo-random function based on the dot product.
float rand(vec3 n) {
    const vec3 randomVec = vec3(12.9898, 78.233, 54.53);
    const float randomConst = 43758.5453;
    return fract(sin(dot(n, randomVec)) * randomConst);
}

// Compute 3D Perlin noise value at point p.
float perlin(vec3 p) {
    // Determine grid cell and relative position
    vec3 cell = floor(p);
    vec3 pos = fract(p);
    
    // Compute smooth step curve for interpolation
    vec3 fadeCurve = pos * pos * (3.0 - 2.0 * pos);

    // Directly interpolate using random values for each corner of the cube
    float l0 = mix(
        mix(rand(cell), rand(cell + vec3(1.0, 0.0, 0.0)), fadeCurve.x),
        mix(rand(cell + vec3(0.0, 1.0, 0.0)), rand(cell + vec3(1.0, 1.0, 0.0)), fadeCurve.x),
        fadeCurve.y
    );
    float l1 = mix(
        mix(rand(cell + vec3(0.0, 0.0, 1.0)), rand(cell + vec3(1.0, 0.0, 1.0)), fadeCurve.x),
        mix(rand(cell + vec3(0.0, 1.0, 1.0)), rand(cell + vec3(1.0, 1.0, 1.0)), fadeCurve.x),
        fadeCurve.y
    );

    // Final interpolation along the z-axis
    float result = mix(l0, l1, fadeCurve.z);
    
    // Enhance contrast of the result
    return result * result * (3.0 - 2.0 * result);
}

// Fractional Brownian Motion combining multiple octaves of Perlin noise.
float PerlinFBM(vec3 p, int octaves) {
    float totalValue = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    // Loop over octaves to accumulate noise values
    for (int i = 0; i < octaves; i++) {
        totalValue += amplitude * perlin(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return totalValue;
}

void main() {
    vec4 controlledColor = u_Color;

    // Use the normal to influence the color's luminance.
    vec3 adjustedNormal = fs_Nor.xyz * 0.5 + 0.5;

    // Compute luminance using the Rec. 709 formula
    float luminance = dot(controlledColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 luminanceColor = vec3(luminance, luminance, luminance);

    // Blend controlledColor with luminanceColor based on the adjustedNormal
    vec3 shadedColor = mix(controlledColor.rgb, luminanceColor, 1.0 - adjustedNormal.x);

    // Grid cell scale
    float scale = 10.f;

    // Adding 3D Perlin noise effect with multiple octaves
    float n = PerlinFBM(fs_Pos.xyz * scale + vec3(u_Time), 4); // 4 octaves

    // Modulate the color using the noise
    shadedColor *= 1.0 + 0.5 * (n - 0.5); 

    out_Col = vec4(shadedColor, controlledColor.a); // Retaining the original alpha value
}

