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

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// vec3 random3(vec3 p) {
//     return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 23.2)),
//                           dot(p, vec3(269.5, 183.3, 346.3)),
//                           dot(p, vec3(420.6, 631.2, 282.3))
//                     )) * 43758.5453);
// }

// float surflet(vec3 p, vec3 gridPoint) {
//     // Compute the distance between p and the grid point along each axis, and warp it with a
//     // quintic function so we can smooth our cells
//     vec3 t2 = abs(p - gridPoint);
//     vec3 t = vec3(1.f) - 6.f * pow(t2, vec3(5.f)) + 15.f * pow(t2, vec3(4.f)) - 10.f * pow(t2, vec3(3.f));
//     vec3 gradient = random3(gridPoint) * 2.f - vec3(1.f, 1.f, 1.f);
//     vec3 diff = p - gridPoint;
//     float height = dot(diff, gradient);
//     return height * t.x * t.y * t.z;
// }

// float perlinNoise3D(vec3 p) {
// 	float surfletSum = 0.f;
// 	// Iterate over the four integer corners surrounding uv
// 	for(int dx = 0; dx <= 1; ++dx) {
// 		for(int dy = 0; dy <= 1; ++dy) {
// 			for(int dz = 0; dz <= 1; ++dz) {
// 				surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
// 			}
// 		}
// 	}
// 	return surfletSum;
// }

float noise3D(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 269.5, 631.2))) * 43758.5453);
}

float interpNoise3D(vec3 p) {
    int intX = int(floor(p[0]));
    float fractX = fract(p[0]);
    int intY = int(floor(p[1]));
    float fractY = fract(p[1]);
    int intZ = int(floor(p[2]));
    float fractZ = fract(p[2]);

    float v1 = noise3D(vec3(intX, intY, intZ));
    float v2 = noise3D(vec3(intX + 1, intY, intZ));
    float v3 = noise3D(vec3(intX, intY + 1, intZ));
    float v4 = noise3D(vec3(intX + 1, intY + 1, intZ));
    float v5 = noise3D(vec3(intX, intY, intZ + 1));
    float v6 = noise3D(vec3(intX + 1, intY, intZ + 1));
    float v7 = noise3D(vec3(intX, intY + 1, intZ + 1));
    float v8 = noise3D(vec3(intX + 1, intY + 1, intZ + 1));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);
    float i3 = mix(v5, v6, fractX);
    float i4 = mix(v7, v8, fractX);

    float m0 = mix(i1, i2, fractY);
    float m1 = mix(i3, i4, fractY);

    return mix(m0, m1, fractZ);
}

float fbm(vec3 p) {
    float total = 0.f;
    float persistence = 0.75f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5f;

    for(int i = 1; i <= octaves; i++) {
        total += interpNoise3D(vec3(p[0] * freq,
                                    p[1] * freq,
                                    p[2] * freq)) * amp;

        freq *= 2.f;
        amp *= persistence;
    }

    return total;
}

void main()
{
    float fbmValue = fbm(vec3(fs_Nor[0], fs_Nor[1], fs_Nor[2]));
    float f = fbmValue * 3.f;
    out_Col = u_Color * (f - floor(f));
}
