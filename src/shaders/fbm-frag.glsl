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
uniform int u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float noise3D(vec3 v) {
    return fract(sin(dot(v, vec3(78, 13, 37))) * 43758.5453);
}

float mySmoothStep(float a, float b, float t) {
    //t = smoothstep(0, 1, t);
    //return mix(a, b, t);
    return 1.f;
}

float interpNoise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    
    float a = noise3D(vec3(i.x, i.y, i.z));
    float b = noise3D(vec3(i.x + 1.f, i.y, i.z + 1.f));
    float c = noise3D(vec3(i.x, i.y + 1.f, i.z));
    float d = noise3D(vec3(i.x + 1.f, i.y + 1.f, i.z + 1.f));

    
    vec3 v = f * f * (3.0 - 2.0 * f);
    /*vec3 v = vec3(f.x * f.x * (3.0 - (2.0 * f.x)), 
                f.y * f.y * (3.0 - (2.0 * f.y)),
                f.z * f.z * (3.0 - (2.0 * f.z)));
    */
    
    return mix(a, b, v.x) + 
            (c - a) * v.y * (1.0 - v.x) +
            (d - b) * v.z * v.y;
}


/*float fbm(vec3 v) {
    float total = 0.f;
    float persistence = 0.5f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5f;

    for (int i = 0; i <= octaves; i++) {
        total += interpNoise3D(v.x * freq,
                                v.y * freq,
                                v.z * freq);
        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}*/

float fbm(vec3 v) {
    float total = 0.f;
    int octaves = 5;
    float amp = 0.5f;
    vec3 shift = vec3(100.0);

    mat3 rot = mat3(cos(0.5), sin(0.5), -cos(0.5),
                    -sin(0.5), cos(0.5), sin(0.5), 
                    -cos(0.5), -sin(0.5), cos(0.5));

    for (int i = 0; i < octaves; i++) {
        total += amp * interpNoise3D(v);

        v = rot * v * 2.0 + shift;
        amp *= 0.5;
    }
    return total;
}


void main()
{
    /*
    vec3 v = fs_Pos.xyz * 3.f;
    vec3 color = vec3(0.f);

    vec3 q = vec3(0.f);
    q.x = fbm(v);
    q.y = fbm(v + vec3(1.0));
    q.z = fbm(v + vec3(0.5));

    vec3 r = vec3(0.f);
    r.x = fbm(v + q + vec3(1.7, 9.2, 3.1) + vec3(0.15 * u_Time));
    r.y = fbm(v + q + vec3(8.3, 2.8, 6.7) + vec3(0.126 * u_Time));
    r.z = fbm(v + q + vec3(5.4, 8.3, 4.6) + vec3(0.132 * u_Time));

    float f = fbm(v + r);

    color = mix(u_Color, 
                u_Color * 0.7, 
                clamp((f * f) * 4.f, 0.f, 1.f));

    color = mix(color, 
                u_Color * 0.1, 
                clamp(length(q), 0.f, 1.f));

    color = mix(color, 
                u_Color * 0.3, 
                clamp(length(r.x), 0.f, 1.f));

    color *= ((f * f * f) + (0.6 * f * f) + (0.5 * f))
    vec4 diffuseColor = vec4(color.x, color.y, color.z, 1.f);

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;

    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
    */
    


    // Material base color (before shading)
    vec3 c1 = u_Color.xyz;
    vec3 c2 = vec3(fbm(fs_Pos.xyz), 
                    fbm(fs_Pos.xyz + vec3(1.0)), 
                    fbm(fs_Pos.xyz + vec3(0.5)));

    vec3 col = mix(c1, c2, 0.5);
    vec4 diffuseColor = vec4(col.x, col.y, col.z, u_Color.w);


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