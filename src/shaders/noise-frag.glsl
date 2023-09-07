#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
in vec4 fs_Pos;
out vec4 out_Col;
const float PI = 3.1415926535;
const float density = 4.0f;
float cos_lerp(float a, float b, float t) {
    float mu2 = (1.0 - cos(t * PI)) / 2.0;
    return (a * (1.0 - mu2) + b * mu2);
}
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
    vec3 f = local * local + (3.0 - 2.0 * local);
    // smoothstep(0.0, 1.0, local); // used for interpolation

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

    // // interpolate along x
    // float dots_x[4];
    // for (int i=0; i<4; ++i) {
    //     dots_x[i] = cos_lerp(dots[i], dots[i + 4], f.x);
    // }
    // // interpolate along y
    // float dots_y[2];
    // for (int i=0; i<2; ++i) {
    //     dots_y[i] = cos_lerp(dots_x[i], dots_x[i + 2], f.y);
    // }
    // // interpolate along z
    // return cos_lerp(dots_y[0], dots_y[1], f.z);
}

void main()
{
    float noise = perlin(vec3(fs_Pos * 4.5 + u_Time * 0.25));
    noise = (noise + 1.0) / 2.0;
    out_Col = vec4(vec3(1.0) * noise, 1.0);
}