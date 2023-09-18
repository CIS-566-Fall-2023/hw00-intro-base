#version 300 es

precision highp float;

uniform vec4 u_Color;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;  // Assuming you have 3D position information

out vec4 out_Col;

float random(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 54.53))) * 43758.5453);
}

// Fade function for smooth interpolation
float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}


// 3D Simplified "Perlin-like" noise function
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
    
    // 3D Perlin noise based on fragment position
    float noiseValueR = perlin(fs_Pos.xyz * 5.0); // Scale for detail
    float noiseValueG = perlin(fs_Pos.xyz * 5.0 + 5.0);
    float noiseValueB = perlin(fs_Pos.xyz * 3.0 + 1.0);
    
    // Combine 3D Perlin noise with Lambert shading*/
    float red = diffuseColor.r * lightIntensity * noiseValueR;
    float green = diffuseColor.g * lightIntensity * noiseValueG;
    float blue = diffuseColor.b * lightIntensity * noiseValueB;
    
    out_Col = vec4(red, green, blue, diffuseColor.a);
    //out_Col = vec4(1.0,0.0,0.0,1.0);
}
