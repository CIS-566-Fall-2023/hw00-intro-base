#version 300 es

precision highp float;
const float PI = 3.14159265359;

uniform vec4 u_Color;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

uniform float u_Time;
out vec4 out_Col;

const int p[512] = int[512](
    151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,
    136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,229,92,239,70,61,28,191,78,107,196,75,67,5,
    82,173,49,39,99,73,19,77,80,81,60,65,4,13,47,76,89,134,59,82,161,2,79,32,141,58,65,207,255,139,22,37,
    240,166,113,94,248,186,146,84,96,230,4,223,234,213,23,123,249,215,40,80,161,104,44,217,36,178,26,142,
    4,114,5,109,163,32,82,124,209,121,59,205,90,50,168,156,136,210,208,192,166,78,66,203,94,224,219,29,42,
    113,223,25,215,125,63,15,66,208,57,163,50,220,28,210,211,9,22,172,203,17,24,18,200,91,172,98,145,149,
    228,121,231,197,44,20,101,163,179,141,221,46,125,50,207,210,16,99,80,55,34,214,48,65,104,41,121,57,73,
    180,221,143,95,87,242,234,204,42,209,76,239,94,176,156,238,107,11,163,249,18,48,89,72,188,142,14,120,
    58,221,71,130,88,157,126,20,215,22,210,172,133,145,128,9,208,228,41,15,232,8,96,66,208,239,171,10,237,
    63,170,171,39,9,95,167,179,91,220,101,102,215,225,181,122,145,36,8,232,40,221,227,203,128,182,240,152,
    129,163,60,206,235,159,7,173,102,65,171,39,213,233,58,86,166,141,241,187,88,148,194,247,100,234,140,
    57,121,62,207,40,241,12,153,119,178,221,162,129,20,165,109,68,129,2,44,154,163,70,221,153,101,155,167,
    43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,
    168,141,63,15,23,244,78,79,238,171,48,95,206,73,157,203,83,229,5,254,110,151,170,44,147,142,238,58,74,
    223,254,96,2,165,118,31,136,164,11,18,173,81,43,20,123,15,66,239,78,206,54,131,166,141,41,63,15,5,15,
    64,179,228,221,115,243,112,170,44,207,114,109,248,53,140,36,14,4,56,130,202,28,160,209,222,22,83,13,
    41,9,12,18,228,148,19,207,59,19,10,208,138,37,60,3,182,243,128,165,82,161,3,207,0,91,70,91,90,37,203,
    3,86,3,163,44,30,170,77,139,68,6,48,29,142,60,99,153,0,222,19,67,96,255,162,182,129,91,66,255,255,74,
    13,45,115,77,129,150,132,114,38,53,79,68,166,173,38,170,72,75,112,7,65,70,24,166,103,122,83,235,221,163,
    57,206,32,163,253,31,6,141,13,191,230,66,104,65,153,45,15,176,84,187,22
);

vec3 fade(vec3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float grad(int hash, vec3 dir) {
    int h = hash & 15;
    float grad = 1.0 + (h & 7); // Gradient value is one of 1.0, 2.0, ..., 8.0
    return (h & 8 ? -grad : grad) * dot(dir); // and a random orientation
}

// The main function to compute 3D Perlin Noise
float perlin(vec3 pos) {
    vec3 cell = floor(pos);
    vec3 relPos = pos - cell;
    cell = mod(cell, 256.0);
    vec3 fadeVal = fade(relPos);

    // Hash coordinates
    int a = p[int(cell.x)];
    int b = p[int(cell.y)];
    int aa = p[a + int(cell.z)];
    int ab = p[a + 1 + int(cell.z)];
    int ba = p[b + int(cell.z)];
    int bb = p[b + 1 + int(cell.z)];

    // Gradient directions
    vec3 dir0 = relPos - vec3(0.0, 0.0, 0.0);
    vec3 dir1 = relPos - vec3(1.0, 0.0, 0.0);
    vec3 dir2 = relPos - vec3(0.0, 1.0, 0.0);
    vec3 dir3 = relPos - vec3(1.0, 1.0, 0.0);
    vec3 dir4 = relPos - vec3(0.0, 0.0, 1.0);
    vec3 dir5 = relPos - vec3(1.0, 0.0, 1.0);
    vec3 dir6 = relPos - vec3(0.0, 1.0, 1.0);
    vec3 dir7 = relPos - vec3(1.0, 1.0, 1.0);

    // Compute noise contributions from each corner of the cube
    float n0 = grad(aa, dir0);
    float n1 = grad(ab, dir1);
    float n2 = grad(ba, dir2);
    float n3 = grad(bb, dir3);
    float n4 = grad(aa + 1, dir4);
    float n5 = grad(ab + 1, dir5);
    float n6 = grad(ba + 1, dir6);
    float n7 = grad(bb + 1, dir7);

    // Compute the final noise value at pos
    float n = mix(mix(mix(n0, n1, fadeVal.x),
                      mix(n2, n3, fadeVal.x), fadeVal.y),
                  mix(mix(n4, n5, fadeVal.x),
                      mix(n6, n7, fadeVal.x), fadeVal.y), fadeVal.z);
    return n;
}

void main()
{
    float noise = perlin(fs_Col.xyz * vec3(1.630, 2.780, 2.050));
    vec3 diffuseColor = vec3(u_Color.x + noise, u_Color.y + noise, u_Color.z + noise);

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;

    out_Col = vec4(diffuseColor.rgb * lightIntensity, u_Color.a);
}

