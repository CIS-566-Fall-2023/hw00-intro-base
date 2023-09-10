#version 300 es

// custom fragment shader that implements FBM, Worley Noise, or Perlin Noise
// based on 3D inputs
// noise must be used to modify your fragment color

precision highp float;
uniform vec4 u_Color; 
uniform float u_Time;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

// define a gradient at each integer point on the lattice
// Function to generate random gradients at grid points

vec3 random3(vec3 st) {
    float rand = fract(sin(dot(st, vec3(12.9898, 78.233, 45.5431))) * 43758.5453);
    return normalize(fract(vec3(2.0, 3.0, 5.0) * rand));
}

// interpolate between 8 surrounding corners
float noise(vec3 st) {
    vec3 i = floor(st);
    vec3 f = fract(st);

    vec3 u = f * f * (3.0 - 2.0 * f);

    float c1 = dot(random3(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0));
    float c2 = dot(random3(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0));
    float c3 = dot(random3(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0));
    float c4 = dot(random3(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0));
    float c5 = dot(random3(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0));
    float c6 = dot(random3(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0));
    float c7 = dot(random3(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0));
    float c8 = dot(random3(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0));

    return mix(
        mix(mix(c1, c2, u.x), mix(c3, c4, u.x), u.y),
        mix(mix(c5, c6, u.x), mix(c7, c8, u.x), u.y),
        u.z
    );

}

void main()
{
        vec4 diffuseColor = u_Color;
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        float ambientTerm = 0.5; // this used to be 0.2
        float lightIntensity = diffuseTerm + ambientTerm;   

        float redComponent = 0.5 + 0.5 * sin(u_Time * 0.002);
        float greenComponent = 0.5 + 0.5 * cos(u_Time * 0.003);
        float blueComponent = 0.5 + 0.5 * sin(u_Time * 0.004); // A faster oscillation

        vec4 dynamicColor = vec4(redComponent, greenComponent, -blueComponent, 1);
        vec4 dynamicColor2 = vec4(blueComponent, -redComponent, greenComponent, 1);
        vec4 dynamicColor3 = vec4(-greenComponent, blueComponent, redComponent, 1);

        diffuseColor = dynamicColor;
    
        // noise

        vec3 st = fs_Pos.xyz * 1.7;
        
        float sinTime = 1.5 * (sin(u_Time * 0.002) + 1.0) - 4.0;        
        float noiseOutput = (noise(st))  * sinTime;
        float noiseFract = fract(noiseOutput * 10.0) ;

        vec4 noiseVec = vec4(vec3(noiseFract), 1.0);
        noiseVec *= 2.0; // color remapping
        noiseVec = floor(noiseVec * 2.0 + 1.0) / 2.0;

        noiseVec = vec4(noiseVec.xyz, 1.0);

        float luminance = 0.2126 * noiseVec.r + 0.7152 * noiseVec.g + 0.0722 * noiseVec.b;
        
        if (luminance > 0.9) {
            diffuseColor = dynamicColor2;
        }

        // noise2

        float sinTime2 = 1.5 * (cos(u_Time * 0.002) + 1.0) - 4.0;        
        float noiseOutput2 = (noise(st * 1. ))  * sinTime;
        float noiseFract2 = fract(noiseOutput2 * 20.0) ;

        vec4 noiseVec2 = vec4(vec3(noiseFract2), 1.0);
        noiseVec2 *= 3.0; // color remapping
        noiseVec2 = floor(noiseVec2 * 10.0 + 1.0) / 20.0;

        noiseVec2 = vec4(noiseVec2.xyz, 1.0);

        float luminance2 = 0.2126 * noiseVec2.r + 0.7152 * noiseVec2.g + 0.0722 * noiseVec2.b;
        
        if (luminance2 > 0.96) {
            diffuseColor = dynamicColor3;
        }

        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

}