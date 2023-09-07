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
uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const float density = 2.5f;
float hash(vec3 p3) {
	p3  = fract(p3 * vec3(.1031,.11369,.13787));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}
vec3 grad(vec3 p) {
    return normalize(-1.0 + 2.0 * vec3(hash(p.xyz), hash(p.yxy), hash(p.zyx)));
}
vec3 fade(vec3 p, vec3 corner) {
    vec3 t = abs(p - corner);
    return vec3(1.f) - (6.0*t*t*t*t*t - 15.0*t*t*t*t + 10.0*t*t*t);
}
float perlin(vec3 p) {
    p *= density;
    vec3 min_corner = floor(p); // min corner of the cell
    vec3 local = fract(p); // fraction of the point within the cell

    vec3 gs[8]; // gradients at each corner
    vec3 falloffs[8]; // falloff values
    for (int dx=0; dx<=1; ++dx) {
        for (int dy=0; dy<=1; ++dy) {
            for (int dz=0; dz<=1; ++dz) {
                vec3 corner = min_corner + vec3(dx, dy, dz);
                gs[dx + 2 * dy + 4 * dz] = grad(corner);
                falloffs[dx + 2 * dy + 4 * dz] = fade(p, corner);
            }
        }
    }
    vec3 vs[8]; // distance vectors from each corner to the point
    for (int dx=0; dx<=1; ++dx) {
        for (int dy=0; dy<=1; ++dy) {
            for (int dz=0; dz<=1; ++dz) {
                vs[dx + 2 * dy + 4 * dz] = local - vec3(dx, dy, dz);
            }
        }
    }
    float dots[8]; // dot products of gradients and distance vectors
    float ret = 0.0;
    for (int i=0; i<8; ++i) {
        dots[i] = dot(gs[i], vs[i]);
        dots[i] *= falloffs[i].x * falloffs[i].y * falloffs[i].z;
        ret += dots[i];
    }
    return ret;
}

void main()
{
    // Material base color (before shading)
    float noise = (perlin(fs_Pos * 4.5 + u_Time * 0.25) + 1.0) / 2.0;
    vec4 diffuseColor = vec4(u_Color.rgb * step(0.5f, noise), 1.0);

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
