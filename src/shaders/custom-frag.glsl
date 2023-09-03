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
uniform float u_Time; // Current time
uniform float u_VoronoiScale;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec3 fs_Nor;
in vec3 fs_Pos;
in vec3 fs_Col;
in vec2 fs_Uv;
in vec3 fs_ViewPos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const float Pi = 3.1415926535897932;
const float PiInv = 1.0 / Pi;

vec2 sphereToPlane(vec3 uv) {
	float theta = atan(uv.y, uv.x);
	if (theta < 0.0) {
        theta += Pi * 2.0;
    }
	float phi = atan(length(uv.xy), uv.z);
	return vec2(theta * PiInv * 0.5, phi * PiInv);
}

vec2 toConcentricDisk(vec2 v) {
	if (v.x == 0.0 && v.y == 0.0) {
        return vec2(0.0, 0.0);
    }
	v = v * 2.0 - 1.0;
	float phi, r;

	if (v.x * v.x > v.y * v.y) {
		r = v.x;
		phi = Pi * v.y / v.x * 0.25;
	}
	else {
		r = v.y;
		phi = Pi * 0.5 - Pi * v.x / v.y * 0.25;
	}
	return vec2(r * cos(phi), r * sin(phi));
}

uint hash(uint seed) {
    seed = (seed ^ uint(61)) ^ (seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> uint(4));
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> uint(15));
    return seed;
}

float rand(inout uint seed) {
    seed = hash(seed);
    return float(seed) * (1.0 / 4294967296.0);
}

vec2 floatMod(vec2 v, vec2 m) {
    return fract((v + m * 10.0) / m) * m;
}

float VoronoiNoise(vec2 uv, vec2 scale, float time) {
    uv = uv * scale + time;

    float minDist = 2.;
    vec2 base = floor(uv);
    vec2 closest;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec2 cell = base + vec2(i, j);
            vec2 modCell = floatMod(cell, scale);
            uint seed = floatBitsToUint((modCell.x + 1.0) * (modCell.y + 1.0));
            vec2 cellPos = cell + vec2(rand(seed), rand(seed));

            if (length(cellPos - uv) < minDist) {
                minDist = length(cellPos - uv);
                closest = cell;
            }
        }
    }
    uint seed = floatBitsToUint((closest.x + 1.0) * (closest.y + 1.0));
    //return minDist * rand(seed);
    return mix(0.1, 1.0, 1.0 - pow(minDist, 1.1));
    //return rand(seed);
}

vec3 lightPosition(float time) {
    return vec3(5, 5, 3);
    //return vec3(cos(time), sin(time), 0.6) * 5.0;
}

void main()
{
    vec2 uv = sphereToPlane(normalize(vec3(fs_Uv * 2.0 - 1.0, 1.0)));
    //vec2 uv = toConcentricDisk(fs_Uv);

    // Material base color (before shading)
    vec3 diffuseColor = u_Color.rgb * VoronoiNoise(uv, vec2(u_VoronoiScale), u_Time);

    // Calculate the diffuse term for Lambert shading

    vec3 wi = normalize(lightPosition(u_Time) - fs_Pos);

    vec3 dx = dFdx(fs_ViewPos);
    vec3 dy = dFdy(fs_ViewPos);
    vec3 n = normalize(cross(dx, dy));

    float diffuseTerm = max(dot(n, wi), 0.0);
    // Avoid negative lighting values
    // diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

    // Compute final shaded color
    out_Col = vec4(diffuseColor * lightIntensity, 1.0);
    //out_Col = vec4(vec3(floor(u_FragmentTime)), 1.0);
}
