const float density = 2.5;
const float PI = 3.1415926535;

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
    return vec3(1.0) - (6.0*t*t*t*t*t - 15.0*t*t*t*t + 10.0*t*t*t);
}
float perlin(vec3 p) {
    p *= density;
    vec3 min_corner = floor(p); // min corner of the cell
    vec3 local = fract(p); // fraction of the point within the cell
    float ret = 0.0;
    for (int dx=0; dx<=1; ++dx) {
        for (int dy=0; dy<=1; ++dy) {
            for (int dz=0; dz<=1; ++dz) {
                vec3 corner = min_corner + vec3(dx, dy, dz);
                vec3 g = grad(corner);
                vec3 d = local - vec3(dx, dy, dz);
                vec3 f = fade(p, corner);
                ret += dot(g, d) * f.x * f.y * f.z;
            }
        }
    }
    return ret;
}