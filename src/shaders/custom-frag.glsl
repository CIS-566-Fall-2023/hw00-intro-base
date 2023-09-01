#version 300 es

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

// A random3 shamelessly stolen from shadertoy
vec3 hash33(vec3 p3) {
	vec3 p = fract(p3 * vec3(.1031,.11369,.13787));
    p += dot(p, p.yxz+19.19);
    return fract(vec3((p.x + p.y)*p.z, (p.x+p.z)*p.y, (p.y+p.z)*p.x));
}

float quinticsmooth(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float surflet(vec3 p, vec3 gridP) {
    vec3 gradient = 2.0 * hash33(gridP) - 1.f;
    vec3 diff = p - gridP;
    float h = dot(diff, gradient);
    for (int i = 0; i < 3; i++) {
        h *= 1.0 - quinticsmooth(abs(p[i] - gridP[i]));
    }
    return h;
}

float perlin(vec3 p) {
    float res = 0.0;
    vec3 cell = floor(p);
    for (int x = 0; x <= 1; x++) {
    for (int y = 0; y <= 1; y++) {
    for (int z = 0; z <= 1; z++) {
        res += surflet(p, cell + vec3(float(x), float(y), float(z)));
    }
    }
    }
    return res;
}

float SqWorleyNoise(vec3 pos, float scale) {
    pos *= scale;
    vec3 intPos = floor(pos);
    vec3 fracPos = fract(pos);
    float minDist2 = 1.0; // Min dist squared initialized to max.

    for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
    for (int z = -1; z <= 1; z++) {
        vec3 neighbor = vec3(float(x), float(y), float(z)); //Direction of neighbor cell
        vec3 point = hash33(intPos + neighbor); // Neigbor cell voranoi point
        vec3 diff = neighbor + point - fracPos; // Distance
        float dist2 = dot(diff, diff);
        minDist2 = min(minDist2, dist2);
    }
    }
    }

    return minDist2;
}

void main()
{
    // Material base color (before shading)
    vec4 diffuseColor = u_Color;
    diffuseColor *= 1.0 - SqWorleyNoise(vec3(fs_Pos), 1.0);

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
