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
uniform float u_Time; // The time values for the shader

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.
#define NUM_OCTAVES 6

float hash(vec3 p3) {
	p3  = fract(p3 * vec3(.1031,.11369,.13787));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 grad(vec3 p) {
    return normalize(2.0 * vec3(hash(p.xyz), hash(p.yxy), hash(p.zyx))-1.0);
}
vec3 fade(vec3 p, vec3 corner) {
    vec3 t = abs(p - corner);
    return vec3(1.0) - ((6.0*t - 15.0)*t + 10.0)*t*t*t;
}

float perlin(vec3 p) {
    vec3 p0 = floor(p);
    vec3 local = fract(p);
    vec3 p1 = p0 + vec3(1.0, 0.0, 0.0);
    vec3 p2 = p0 + vec3(0.0, 1.0, 0.0);
    vec3 p3 = p0 + vec3(1.0, 1.0, 0.0);
    vec3 p4 = p0 + vec3(0.0, 0.0, 1.0);
    vec3 p5 = p0 + vec3(1.0, 0.0, 1.0);
    vec3 p6 = p0 + vec3(0.0, 1.0, 1.0);
    vec3 p7 = p0 + vec3(1.0, 1.0, 1.0);

    vec3 g0 = grad(p0);
    vec3 g1 = grad(p1);
    vec3 g2 = grad(p2);
    vec3 g3 = grad(p3);
    vec3 g4 = grad(p4);
    vec3 g5 = grad(p5);
    vec3 g6 = grad(p6);
    vec3 g7 = grad(p7);

    vec3 t0 = fade(p, p0);
    vec3 t1 = fade(p, p1);
    vec3 t2 = fade(p, p2);
    vec3 t3 = fade(p, p3);
    vec3 t4 = fade(p, p4);
    vec3 t5 = fade(p, p5);
    vec3 t6 = fade(p, p6);
    vec3 t7 = fade(p, p7);

    float ret = 0.0;
    ret += dot(g0, p-p0)*t0.x*t0.y*t0.z;
    ret += dot(g1, p-p1)*t1.x*t1.y*t1.z;
    ret += dot(g2, p-p2)*t2.x*t2.y*t2.z;
    ret += dot(g3, p-p3)*t3.x*t3.y*t3.z;
    ret += dot(g4, p-p4)*t4.x*t4.y*t4.z;
    ret += dot(g5, p-p5)*t5.x*t5.y*t5.z;
    ret += dot(g6, p-p6)*t6.x*t6.y*t6.z;
    ret += dot(g7, p-p7)*t7.x*t7.y*t7.z;
    
    return ret;
}

float offset = 1.0;
float fbm(vec3 x) {
	float res = 0.0;
	float a = 1.0;
	float frequency = 0.005;
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		res += a * perlin(x);
		a *= 0.5;
        x *= 2.0;
	}
	return res;
}

void main()
{
    // Material base color (before shading)
        vec3 noise = vec3(fbm(fs_Pos.xyz),fbm(fs_Pos.yzx),fbm(fs_Pos.zxy));
        vec4 diffuseColor = vec4(noise*u_Color.xyz,1.0);

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 1.0;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
