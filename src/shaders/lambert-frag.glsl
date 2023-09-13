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
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


vec3 fade(vec3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

int hash(vec3 p) {
    vec3 p3 = fract(p * vec3(0.1031, 0.11369, 0.13787));
    p3 += dot(p3, p3.yzx + 19.19);
    return int(fract(p3.x * p3.y * p3.z) * 43758.5453);
}


const vec3[12] gradients = vec3[](
    vec3(1,1,0),vec3(-1,1,0),vec3(1,-1,0),vec3(-1,-1,0),
    vec3(1,0,1),vec3(-1,0,1),vec3(1,0,-1),vec3(-1,0,-1),
    vec3(0,1,1),vec3(0,-1,1),vec3(0,1,-1),vec3(0,-1,-1)
);

float grad(int hash, vec3 pos) {
    int h = hash & 15;
    vec3 grad = gradients[h % 12];
    return dot(grad, pos);
}


float perlin(vec3 p) {
    vec3 pi = floor(p); // integer part
    vec3 pf = fract(p); // fractional part

    vec3 w = fade(pf);

    // Hash coordinates of the cube
    int h0 = hash(pi);
    int h1 = hash(pi + vec3(1.0, 0.0, 0.0));
    int h2 = hash(pi + vec3(0.0, 1.0, 0.0));
    int h3 = hash(pi + vec3(1.0, 1.0, 0.0));
    int h4 = hash(pi + vec3(0.0, 0.0, 1.0));
    int h5 = hash(pi + vec3(1.0, 0.0, 1.0));
    int h6 = hash(pi + vec3(0.0, 1.0, 1.0));
    int h7 = hash(pi + vec3(1.0, 1.0, 1.0));

    float n0 = grad(h0, pf);
    float n1 = grad(h1, pf - vec3(1.0, 0.0, 0.0));
    float n2 = grad(h2, pf - vec3(0.0, 1.0, 0.0));
    float n3 = grad(h3, pf - vec3(1.0, 1.0, 0.0));
    float n4 = grad(h4, pf - vec3(0.0, 0.0, 1.0));
    float n5 = grad(h5, pf - vec3(1.0, 0.0, 1.0));
    float n6 = grad(h6, pf - vec3(0.0, 1.0, 1.0));
    float n7 = grad(h7, pf - vec3(1.0, 1.0, 1.0));

    // Interpolate along x
    float nx0 = mix(n0, n1, w.x);
    float nx1 = mix(n2, n3, w.x);
    float nx2 = mix(n4, n5, w.x);
    float nx3 = mix(n6, n7, w.x);

    // Interpolate along y
    float nxy0 = mix(nx0, nx1, w.y);
    float nxy1 = mix(nx2, nx3, w.y);

    // Interpolate along z
    float nxyz = mix(nxy0, nxy1, w.z);

    return nxyz;
}



const int OCTAVES_WORLEY = 6;
float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float lacunarity = 2.0;
    float persistence = 0.5;
    float maxValue = 0.0;  // Used for normalizing result to [0, 1] range
    
    for(int i = 0; i < OCTAVES_WORLEY; i++) {
        value += amplitude * perlin(p * frequency);
        maxValue += amplitude;
        
        frequency *= lacunarity;
        amplitude *= persistence;
    }

    return value / maxValue;  // Normalize to [0, 1] range
}




void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.
        // Compute final shaded color
        //out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
        out_Col = vec4(diffuseColor.rgb * fbm(fs_Pos.xyz), diffuseColor.a);
}
