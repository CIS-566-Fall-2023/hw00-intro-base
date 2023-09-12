#version 300 es

precision highp float;

uniform vec4 u_Color;
in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col;

vec3 random3(vec3 p) {
    return fract(sin(vec3(dot(p,vec3(127.1, 311.7, 489.61)),
                          dot(p,vec3(777.7, 444.4, 333.3)),
                          dot(p,vec3(269.5, 183.3, 914.5)))) * 43758.5453f);
}

float quinticFalloff(float f) {
    return 1.f - 6.f * pow(f, 5.f) + 15.f * pow(f, 4.f) - 10.f * pow(f, 3.f);
}

float surflet3d(vec3 p, vec3 gridPoint) {
    vec3 dist = abs(p - gridPoint); //distance b/w the corner(grid) point and the point in the grid under consideration
    vec3 falloff = vec3(quinticFalloff(dist.x), quinticFalloff(dist.y), quinticFalloff(dist.z)); //quintic falloff to smoothen out the cells
    // Get the random vector for the grid point (assume we wrote a function random2
    // that returns a vec2 in the range [0, 1])
    vec3 gradient = normalize(2.f * random3(gridPoint) - vec3(1.f, 1.f, 1.f));
    // Get the vector from the grid point to P
    vec3 diff = p - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * falloff.x * falloff.y * falloff.z;
}

float perlin3d(vec3 p) {
    float surfletSum = 0.f;
    p *= 10.5f;
    // Iterate over the eight integer corners surrounding uv
    for(int dx = 0; dx <= 1; ++dx) {
        for(int dy = 0; dy <= 1; ++dy) {
            for(int dz = 0; dz <= 1; dz++) {
                surfletSum += surflet3d(p, floor(p) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum;
}

void main()
{
    // Material base color (before shading)
        vec4 fragColor = u_Color;
        fragColor.rgb += vec3(perlin3d(fs_Pos.xyz), perlin3d(fs_Pos.yzx), perlin3d(fs_Pos.zxy));
        // Compute final shaded color
        out_Col = vec4(fragColor.rgb, fragColor.a);
}
